//
//  Separator.swift
//  merrytime
//
//  Created by tomisacat on 11/05/2017.
//  Copyright © 2017 UnionJoy. All rights reserved.
//

import Foundation
import AVFoundation

struct Separator {
    let video: URL
    
    fileprivate static let group: DispatchGroup = DispatchGroup()
    fileprivate static let queue: DispatchQueue = DispatchQueue(label: "com.test.separator", attributes: .concurrent)
    
    func separateReversed(withCompletion completion: ((URL?, URL?) -> Void)?) {
        var audioUrl: URL?
        var videoUrl: URL?
        
        // video
        Separator.group.enter()
        let video: DispatchWorkItem = DispatchWorkItem(flags: .inheritQoS) {
            self.separateVideo(completion: { (url) in
                videoUrl = url
                print("succeed to separate video part")
                Separator.group.leave()
            })
        }
        Separator.queue.async(execute: video)
        
        // audio
        Separator.group.enter()
        let audio: DispatchWorkItem = DispatchWorkItem(flags: .inheritQoS) {
            self.separateAudio(completion: { (url) in
                audioUrl = url
                print("succeed to separate audio part")
                Separator.group.leave()
            })
        }
        Separator.queue.async(execute: audio)
        
        Separator.group.notify(queue: DispatchQueue.main) {
            print("enter callback")
            completion?(audioUrl, videoUrl)
        }
    }
    
    private enum MediaType: String {
        case video
        case audio
        
        func typeString() -> String {
            switch self {
            case .video:
                return AVMediaTypeVideo
            case .audio:
                return AVMediaTypeAudio
            }
        }
        
        func outputFileType() -> String {
            switch self {
            case .video:
                return AVFileTypeQuickTimeMovie
            case .audio:
                return AVFileTypeAppleM4A
            }
        }
        
        func preset() -> String {
            switch self {
            case .video:
                return AVAssetExportPresetHighestQuality
            case .audio:
                return AVAssetExportPresetAppleM4A
            }
        }
        
        func randomUrl() -> URL {
            switch self {
            case .video:
                return URL(fileURLWithPath: NSTemporaryDirectory() + "/video.mov")
            case .audio:
                return URL(fileURLWithPath: NSTemporaryDirectory() + "/audio.m4a")
            }
        }
    }
    
    private func separateVideo(completion: @escaping (URL?) -> Void) {
        separate(withMediaType: .video, completion: completion)
    }
    
    private func separateAudio(completion: @escaping (URL?) -> Void) {
        separate(withMediaType: .audio, completion: completion)
    }
    
    // separate
    private func separate(withMediaType type: MediaType, completion: @escaping (URL?) -> Void) {
        let asset = AVURLAsset(url: video)
        let track: AVAssetTrack? = asset.tracks(withMediaType: type.typeString()).first
        
        let composition: AVMutableComposition = AVMutableComposition()
        let compositionTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: type.typeString(), preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try compositionTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero,
                                                             duration: (track?.timeRange.duration)!),
                                                 of: track!,
                                                 at: kCMTimeZero)
        } catch {
            completion(nil)
            return
        }
        
        let export: AVAssetExportSession? = AVAssetExportSession(asset: composition, presetName: type.preset())
        export?.outputURL = type.randomUrl()
        export?.outputFileType = type.outputFileType()
        export?.shouldOptimizeForNetworkUse = true
        export?.exportAsynchronously(completionHandler: {
            if export?.status == .completed {
                completion(export?.outputURL)
            } else {
                completion(nil)
            }
        })
    }
}

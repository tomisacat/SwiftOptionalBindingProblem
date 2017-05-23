//
//  ViewController.swift
//  ForcedUnwrappedAVFoundation
//
//  Created by tomisacat on 22/05/2017.
//  Copyright © 2017 tomisacat. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var videoUrl: URL?
    var separator: Separator?

    override func viewDidLoad() {
        super.viewDidLoad()

        videoUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "video", ofType: "mov")!)
        separator = Separator(video: videoUrl!);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // reversed asset track
        var reversedAudioAssetTrack: AVAssetTrack? = nil
        var reversedVideoAssetTrack: AVAssetTrack? = nil
        
        separator?.separateReversed { (audioUrl, videoUrl) in
            let composition: AVMutableComposition = AVMutableComposition()
            let videoCompositionTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioCompositionTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
                if let audio = audioUrl {
                    let reversedAudioAsset = AVURLAsset(url: audio)
                    reversedAudioAssetTrack = reversedAudioAsset.tracks(withMediaType: AVMediaTypeAudio).first
                }
//                let reversedAudioAsset = AVURLAsset(url: audioUrl!)
//                reversedAudioAssetTrack = reversedAudioAsset.tracks(withMediaType: AVMediaTypeAudio).first

            
                if let video = videoUrl {
                    let reversedVideoAsset = AVURLAsset(url: video)
                    reversedVideoAssetTrack = reversedVideoAsset.tracks(withMediaType: AVMediaTypeVideo).first
                }
//                let reversedVideoAsset = AVURLAsset(url: videoUrl!)
//                reversedVideoAssetTrack = reversedVideoAsset.tracks(withMediaType: AVMediaTypeVideo).first
            
            do {
                if let reversedVideoAssetTrack = reversedVideoAssetTrack {
                    try videoCompositionTrack.insertTimeRange(reversedVideoAssetTrack.timeRange, of: reversedVideoAssetTrack, at: kCMTimeZero)
                }
                if let reversedAudioAssetTrack = reversedAudioAssetTrack {
                    try audioCompositionTrack.insertTimeRange(reversedAudioAssetTrack.timeRange, of: reversedAudioAssetTrack, at: kCMTimeZero)
                }
            } catch {
                print("error catched")
                return
            }
            
            let export: AVAssetExportSession? = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            export?.outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "/output.mov")
            export?.outputFileType = AVFileTypeQuickTimeMovie
            export?.shouldOptimizeForNetworkUse = true
            export?.exportAsynchronously(completionHandler: {
                if export?.status == .completed {
                    Swift.print(export?.outputURL ?? "nil")
                } else {
                    print("failed to export")
                }
            })
        }
    }
}


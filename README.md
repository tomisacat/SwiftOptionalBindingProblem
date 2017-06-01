# SwiftOptionalBindingProblem
Demo app illustrate problem with Swift optional binding.

## Environment

* MacBook Pro, 13 inch, late 2013, with macOS 10.12.4
* iPhone 7 with iOS 10.3.1
* Xcode 8.3.2, Swift 3.1

## How to reproduce:

1. build and run it will succeed to export a new audiovisual.
2. uncomment the commented statements in ViewController.swift and comment statements below them:

```swift
// if let audio = audioUrl {
//    let reversedAudioAsset = AVURLAsset(url: audio)
//    reversedAudioAssetTrack = reversedAudioAsset.tracks(withMediaType: AVMediaTypeAudio).first
//}
let reversedAudioAsset = AVURLAsset(url: audioUrl!)
reversedAudioAssetTrack = reversedAudioAsset.tracks(withMediaType: AVMediaTypeAudio).first

// if let video = videoUrl {
//    let reversedVideoAsset = AVURLAsset(url: video)
//    reversedVideoAssetTrack = reversedVideoAsset.tracks(withMediaType: AVMediaTypeVideo).first
// }
let reversedVideoAsset = AVURLAsset(url: videoUrl!)
reversedVideoAssetTrack = reversedVideoAsset.tracks(withMediaType: AVMediaTypeVideo).first
```

3. build and run, the error catched.



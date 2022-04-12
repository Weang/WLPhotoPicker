//
//  AVAsset+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/19.
//

import UIKit
import AVFoundation

public extension AVAsset {
    
    func getVideoThumbnailImage(completion: @escaping (UIImage?) -> Void) {
        let generator = AVAssetImageGenerator(asset: self)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        let time = NSValue(time: CMTime(seconds: 0, preferredTimescale: 1000))
        generator.generateCGImagesAsynchronously(forTimes: [time]) { (_, cgImage, _, _, _) in
            if let image = cgImage {
                completion(UIImage(cgImage: image))
            } else {
                completion(nil)
            }
        }
    }
    
    func thumbnailImage() -> UIImage? {
        let generator = AVAssetImageGenerator(asset: self)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        let time = CMTime(seconds: 0, preferredTimescale: 1000)
        if let image = try? generator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: image)
        }
        return nil
    }
    
}

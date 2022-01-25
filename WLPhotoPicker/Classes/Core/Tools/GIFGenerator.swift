//
//  GIFGenerator.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/17.
//

import UIKit

public class GIFGenerator {

    static public func animatedImageWith(data: Data) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        let count = CGImageSourceGetCount(imageSource)
        if count <= 1 {
            return UIImage(data: data)
        }
        var images: [UIImage] = []
        var duration: Double = 0
        
        for i in 0..<count {
            guard let image = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {
                continue
            }
            images.append(UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up))
            duration += frameDurationAt(index: i, source: imageSource)
        }
        if duration == 0 {
            duration = 0.1 * Double(count)
        }
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    static private func frameDurationAt(index: Int, source: CGImageSource) -> Double {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
        let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0
        }
        var frameDuration: Double = 0
        if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double {
            frameDuration = delayTimeUnclampedProp
        } else if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
            frameDuration = delayTimeProp
        }
        if frameDuration < 0.011 {
            frameDuration = 0.100
        }
        return frameDuration
    }

}

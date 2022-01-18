//
//  ImageGenerator.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/17.
//

import UIKit

public class ImageGenerator {

    // UIImage Data 转对应尺寸图片
    static func resizeImage(from data: Data, targetSize: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        let size = calculate(from: imageSource.size, to: targetSize)
        let maxDimensionInPixels = max(size.width, size.height)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ]
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: downsampledImage, scale: 1.0, orientation: .up)
    }
    
    
    
    static func calculate(from fromFize: CGSize, to targetSize: CGFloat) -> CGSize {
        let scale: CGFloat
        if fromFize.width < fromFize.height {
            scale = fromFize.width / targetSize
        } else {
            scale = fromFize.height / targetSize
        }
        if scale < 1 {
            return fromFize
        }
        return CGSize(width: fromFize.width / scale, height: fromFize.height / scale)
    }
}

//
//  ImageGenerator.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/17.
//

import UIKit

public class ImageGenerator {

    // UIImage Data 转对应尺寸图片
    static func createImage(from data: Data, targetSize: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        let size = getTargetSize(from: imageSource.size, to: targetSize)
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
    
    static fileprivate func getTargetSize(from fromFize: CGSize, to targetSize: CGFloat) -> CGSize {
        let ratio: CGFloat
        if fromFize.width < fromFize.height {
            ratio = fromFize.width / targetSize
        } else {
            ratio = fromFize.height / targetSize
        }
        if ratio < 1 {
            return fromFize
        }
        return CGSize(width: fromFize.width / ratio, height: fromFize.height / ratio)
    }
}

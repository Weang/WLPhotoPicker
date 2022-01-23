//
//  UIImage+Filters.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/22.
//

import UIKit

extension UIImage {
    
    func mosaicImage(level: CGFloat) -> UIImage {
        guard let ciImage = toCIImage() else {
            return self
        }
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(level, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage?.toUIImage() else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let origin = CGPoint(x: (size.width - outputImage.size.width) * 0.5,
                             y: (size.height - outputImage.size.height) * 0.5)
        outputImage.draw(in: CGRect(x: origin.x,
                                    y: origin.y,
                                    width: outputImage.size.width,
                                    height: outputImage.size.height))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    func blurImage(blur: CGFloat) -> UIImage {
        guard let ciImage = toCIImage() else {
            return self
        }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(blur, forKey: "inputRadius")
        guard let outputImage = filter?.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: ciImage.extent) else {
                  return self
              }
        return UIImage(cgImage: cgImage)
    }
    
    func adjustImageFrom(_ adjustInfo: [PhotoEditAdjustMode: Double]) -> UIImage {
        if adjustInfo.map{ $0.value }.filter({ $0 != 0 }).count == 0 {
            return self
        }
        guard var ciImage = toCIImage() else {
            return self
        }
        for (mode, value) in adjustInfo {
            ciImage = ciImage.applyingFilter(mode.filterName,
                                             parameters: [mode.keyName: mode.filterValue(Float(value))])
        }
        return ciImage.toUIImage() ?? self
    }
    
}

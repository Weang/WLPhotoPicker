//
//  UIImage+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

// MARK: CIFilters
public extension UIImage {
    
    func toCIImage() -> CIImage? {
        if let ciImage = self.ciImage {
            return ciImage
        }
        if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
    
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

public extension UIImage {
    
    func thumbnailWith(_ toSize: CGFloat) -> UIImage {
        let imageRatio = size.width / size.height
        let min = min(size.width, size.height)
        let max = max(size.width, size.height)
        let ratio = min / toSize
        let position = (max / ratio - toSize) * -0.5
        let origin: CGPoint
        if imageRatio >= 1 {
            origin = CGPoint(x: position, y: 0)
        } else {
            origin = CGPoint(x: 0, y: position)
        }
        let newSize = CGSize(width: toSize, height: toSize)
        let rect = CGRect(origin: origin, size: CGSize(width: size.width / ratio, height: size.height / ratio))
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: rect)
        defer {
            UIGraphicsEndImageContext()
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    func convertToScale(_ toScale: CGFloat) -> UIImage {
        let scale = self.scale / toScale
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, toScale)
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
}

extension UIImage {
    
    class func imageWithColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        defer {
            UIGraphicsEndImageContext()
        }
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

//
//  UIImage+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

extension UIImage {
    
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

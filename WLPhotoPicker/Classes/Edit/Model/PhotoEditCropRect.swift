//
//  PhotoEditCropRect.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/9.
//

import UIKit

public struct PhotoEditCropRect {
    
    static var identity = PhotoEditCropRect(x: 0, y: 0, width: 1, height: 1)
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    var origin: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    func convertSizeToRect(_ size: CGSize) -> CGRect {
        return CGRect(x: size.width * x,
                      y: size.height * y,
                      width: size.width * width,
                      height: size.height * height)
    }
}

extension PhotoEditCropRect: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
    
}

extension UIImage {
    
    func cropToRect(_ rect: PhotoEditCropRect) -> UIImage {
        if rect == .identity {
            return self
        }
        let toRect = CGRect(x: size.width * rect.x,
                            y: size.height * rect.y,
                            width: size.width * rect.width,
                            height: size.height * rect.height).rounded()
        UIGraphicsBeginImageContextWithOptions(toRect.size, false, 1)
        let drawRect = CGRect(x: -toRect.minX, y: -toRect.minY, width: size.width, height: size.height)
        draw(in: drawRect)
        defer {
            UIGraphicsEndImageContext()
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
}

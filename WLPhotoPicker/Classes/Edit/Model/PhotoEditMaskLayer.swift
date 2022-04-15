//
//  PhotoEditMaskLayer.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/9.
//

import UIKit

protocol PhotoEditMaskLayer {
    var maskImage: UIImage { set get }
    var maskPadding: CGFloat { get }
    var size: CGSize { get }
    var center: CGPoint { set get }
    var id: Double { set get }
    var scale: CGFloat { set get }
    var rotation: CGFloat { set get }
    var translation: CGPoint { set get }
}

extension PhotoEditMaskLayer {
    
    var maskPadding: CGFloat {
        return 8
    }
    
    var imageSize: CGSize {
        let minWidth: CGFloat = 40
        let maxWidth: CGFloat = 200
        let imageRatio = maskImage.size.width / maskImage.size.height
        if imageRatio >= 1 {
            let width = min(maxWidth, max(minWidth, maskImage.size.width))
            let height = width / imageRatio
            return CGSize(width: width, height: height)
        } else {
            let height = min(maxWidth, max(minWidth, maskImage.size.width))
            let width = height * imageRatio
            return CGSize(width: width, height: height)
        }
    }
    
    var size: CGSize {
        let imageSize = self.imageSize
        return CGSize(width: imageSize.width + maskPadding * 2, height: imageSize.height + maskPadding * 2)
    }
    
}

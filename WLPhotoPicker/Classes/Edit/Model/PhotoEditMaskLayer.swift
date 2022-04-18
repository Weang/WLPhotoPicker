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
        let maximumSize: CGFloat = 120
        let imageRatio = maskImage.size.width / maskImage.size.height
        if imageRatio >= 1 {
            let height = maximumSize / imageRatio
            return CGSize(width: maximumSize, height: height)
        } else {
            let width = maximumSize * imageRatio
            return CGSize(width: width, height: maximumSize)
        }
    }
    
    var size: CGSize {
        let imageSize = self.imageSize
        return CGSize(width: imageSize.width + maskPadding * 2, height: imageSize.height + maskPadding * 2)
    }
    
}

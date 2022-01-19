//
//  PhotoEditPasterMaskLayer.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/9.
//

import UIKit

struct PhotoEditPasterMaskLayer: PhotoEditMaskLayer {
    
    var id: Double
    var maskImage: UIImage
    
    var center: CGPoint = .zero
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    var translation: CGPoint = .zero
    
    init(maskImage: UIImage) {
        self.id = Date().timeIntervalSince1970
        self.maskImage = maskImage
    }
    
}

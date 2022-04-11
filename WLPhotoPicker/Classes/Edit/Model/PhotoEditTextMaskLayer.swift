//
//  PhotoEditTextMaskLayer.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/9.
//

import UIKit

struct PhotoEditTextMaskLayer: PhotoEditMaskLayer {
    
    var id: Double
    
    var maskImage: UIImage
    var text: String
    var isWrap: Bool
    var colorIndex: Int
    
    var cropScale: CGFloat = 1
    var center: CGPoint = .zero
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    var translation: CGPoint = .zero
    
    init(text: String, isWrap: Bool, colorIndex: Int, maskImage: UIImage) {
        self.id = Date().timeIntervalSince1970
        self.text = text
        self.isWrap = isWrap
        self.colorIndex = colorIndex
        self.maskImage = maskImage
    }
    
}

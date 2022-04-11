//
//  PhotoEditCropOrientation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/7.
//

import UIKit

enum PhotoEditCropOrientation {
    case left
    case right
}

extension PhotoEditCropOrientation {
    
    var imageOrientation: UIImage.Orientation {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        }
    }
    
}

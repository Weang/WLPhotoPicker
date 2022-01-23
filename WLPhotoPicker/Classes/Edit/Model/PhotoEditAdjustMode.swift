//
//  PhotoEditAdjustMode.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

public enum PhotoEditAdjustMode: Equatable {
    // 亮度
    case brightness
    // 对比度
    case contrast
    // 饱和度
    case saturability
}

extension PhotoEditAdjustMode {
    
    var icon: UIImage? {
        let imageName: String
        switch self {
        case .brightness:
            imageName = "edit_brightness"
        case .contrast:
            imageName = "edit_contrast"
        case .saturability:
            imageName = "edit_saturability"
        }
        return BundleHelper.imageNamed(imageName)
    }
    
    var name: String {
        switch self {
        case .brightness: return "亮度"
        case .contrast: return "对比度"
        case .saturability: return "饱和度"
        }
    }
    
    var minimumValue: CGFloat {
        switch self {
        case .brightness, .contrast, .saturability: return -1
        }
    }
    
    var filterName: String {
        switch self {
        case .brightness, .contrast, .saturability: return "CIColorControls"
        }
    }
    
    var keyName: String {
        switch self {
        case .brightness: return kCIInputBrightnessKey
        case .contrast: return kCIInputContrastKey
        case .saturability: return kCIInputSaturationKey
        }
    }
    
    func filterValue(_ value: Float) -> Float {
        switch self {
        case .brightness:
            return value / 5
        case .contrast:
            return 1 + value * 0.3
        case .saturability:
            return value + 1
        }
    }
}

//
//  PhotoEditItemType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

public enum PhotoEditItemType: Equatable {
    // 涂鸦
    case graffiti
    // 贴纸
    case paster
    // 添加文字
    case text
    // 裁剪
    case crop
    // 马赛克
    case mosaic
    // 滤镜
    case filter
    // 图像处理
    case adjust
}

extension PhotoEditItemType {
    
    var iconImage: UIImage? {
        switch self {
        case .graffiti:
            return BundleHelper.imageNamed("edit_graffiti")
        case .paster:
            return BundleHelper.imageNamed("edit_paster")
        case .text:
            return BundleHelper.imageNamed("edit_text")
        case .crop:
            return BundleHelper.imageNamed("edit_crop")
        case .mosaic:
            return BundleHelper.imageNamed("edit_mosaic")
        case .filter:
            return BundleHelper.imageNamed("edit_filter")
        case .adjust:
            return BundleHelper.imageNamed("edit_adjust")
        }
    }
    
    var canBeHighlight: Bool {
        switch self {
        case .graffiti, .mosaic, .filter, .adjust:
            return true
        default:
            return false
        }
    }
}

public extension PhotoEditItemType {
    
    static var all: [PhotoEditItemType] {
        [.graffiti,
         .paster,
         .text,
         .crop,
         .mosaic,
         .filter,
         .adjust]
    }
    
}

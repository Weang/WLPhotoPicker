//
//  CaptureAspectRatio.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit

public enum CaptureAspectRatio {
    // TODO: 自定义视频比例
//    case ratio1x1
//    case ratio4x3
    case ratio16x9
//    case fullScreen
}

public extension CaptureAspectRatio {
    
    var ratioValue: CGFloat {
        switch self {
//        case .ratio1x1:  return 1
//        case .ratio4x3:  return 3 / 4
        case .ratio16x9: return 9 / 16
//        case .fullScreen: return UIScreen.main.bounds.width / UIScreen.main.bounds.height
        }
    }
    
}

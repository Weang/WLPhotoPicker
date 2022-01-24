//
//  AssetVideoCompressSize.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import AVFoundation
import VideoToolbox

public enum AssetVideoCompressSize {
    case _640x480
    case _960x540
    case _1280x720
    case _1920x1080
    case _3840x2160
}

extension AssetVideoCompressSize {
    
    var size: CGSize {
        switch self {
        case ._640x480:
            return CGSize(width: 640, height: 480)
        case ._960x540:
            return CGSize(width: 960, height: 540)
        case ._1280x720:
            return CGSize(width: 1280, height: 720)
        case ._1920x1080:
            return CGSize(width: 1920, height: 1080)
        case ._3840x2160:
            return CGSize(width: 3840, height: 2160)
        }
    }
    
}

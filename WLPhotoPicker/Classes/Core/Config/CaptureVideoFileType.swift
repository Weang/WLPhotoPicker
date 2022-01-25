//
//  CaptureVideoFileType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import AVFoundation

// 拍摄视频格式
public enum CaptureVideoFileType {
    case mp4
    case mov
}

extension CaptureVideoFileType {
    
    var avFileType: AVFileType {
        switch self {
        case .mov: return .mov
        case .mp4: return .mp4
        }
    }
    
    var suffix: String {
        switch self {
        case .mov: return ".mov"
        case .mp4: return ".mp4"
        }
    }
    
}

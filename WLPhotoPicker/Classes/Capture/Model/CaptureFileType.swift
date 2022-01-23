//
//  CaptureFileType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import AVFoundation

public enum CaptureFileType {
    case mp4
    case mov
}

extension CaptureFileType {
    
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

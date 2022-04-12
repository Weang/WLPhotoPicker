//
//  PickerVideoExportFileType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/17.
//

import UIKit
import AVFoundation

// 视频导出格式
public enum PickerVideoExportFileType {
    case mp4
    case mov
}

extension PickerVideoExportFileType {
    
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

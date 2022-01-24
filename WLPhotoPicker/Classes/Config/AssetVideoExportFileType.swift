//
//  AssetVideoExportFileType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/17.
//

import UIKit
import AVFoundation

public enum AssetVideoExportFileType {
    case mp4
    case mov
}

extension AssetVideoExportFileType {
    
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

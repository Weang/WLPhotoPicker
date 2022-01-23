//
//  AssetMediaType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import MobileCoreServices
import Foundation

public enum AssetMediaType: Equatable {
    case photo
    case video
    case GIF
    case livePhoto
}

extension AssetMediaType {
    
    var isPhoto: Bool {
        !isVideo
    }
    
    var isVideo: Bool {
        self == .video
    }
    
}

//
//  AssetMediaType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import Foundation

public enum AssetMediaType: Equatable {
    case photo
    case video
    case GIF
    case livePhoto
}

extension AssetMediaType {
    
    var isVideo: Bool {
        return self == .video
    }
    
    var isPhoto: Bool {
        return !isVideo
    }
    
}

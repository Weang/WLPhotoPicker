//
//  PHAsset+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit
import Photos

extension PHAsset {
    
    var pixelSize: CGSize {
        CGSize(width: pixelWidth, height: pixelHeight)
    }
    
}

// MARK: Type
extension PHAsset {
    
    var isPhoto: Bool {
        mediaType == .image
    }
    
    var isVideo: Bool {
        mediaType == .video
    }
    
    var isLivePhoto: Bool {
        mediaSubtypes.contains(.photoLive)
    }
    
    var isGIF: Bool {
        if let fileName = value(forKey: "filename") as? String {
            return fileName.uppercased().hasSuffix("GIF")
        } else {
            return false
        }
    }
}

// MARK: Locally video
extension PHAsset {
    
    // 视频资源在本地是否存在
    var isVideoLocallyAvailable: Bool {
        return PHAssetResource.assetResources(for: self)
            .lazy
            .filter {
                $0.type == .video || $0.type == .fullSizeVideo
            }.filter {
                $0.value(forKey: "locallyAvailable") as? Bool == true
            }.count > 0
    }
    
    // 视频资源在本地相册的存储路径
    var locallyVideoFileURL: URL? {
        if #available(iOS 13, *) { // iOS 13 以下的系统没有isCurrent
            return PHAssetResource.assetResources(for: self)
                .lazy
                .filter {
                    $0.type == .video || $0.type == .fullSizeVideo
                }.filter {
                    $0.value(forKey: "isCurrent") as? Bool == true
                }.filter {
                    $0.value(forKey: "locallyAvailable") as? Bool == true
                }.compactMap {
                    $0.value(forKey: "privateFileURL") as? URL
                }.first
        } else {
            return nil
        }
    }
    
}

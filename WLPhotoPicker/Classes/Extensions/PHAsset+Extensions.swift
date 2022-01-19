//
//  PHAsset+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit
import Photos

extension PHAsset {
    
    var isVideoLocallyAvailable: Bool {
        return PHAssetResource.assetResources(for: self)
            .lazy
            .filter {
                $0.value(forKey: "isCurrent") as? Bool == true
            }.filter {
                $0.type == .video || $0.type == .fullSizeVideo
            }.filter {
                $0.value(forKey: "locallyAvailable") as? Bool == true
            }.count > 0
    }
    
    var locallyVideoFileURL: URL? {
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
    }
    
    var fileName: String? {
        return value(forKey: "filename") as? String
    }
    
    var fileSuffix: String? {
        guard let fileName = self.fileName,
              let suffix = fileName.split(separator: ".").last else {
            return nil
        }
        return String(suffix)
    }
    
    var pixelSize: CGSize {
        CGSize(width: pixelWidth, height: pixelHeight)
    }
    
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
        if let fileName = self.fileName {
            return fileName.uppercased().hasSuffix("GIF")
        } else {
            return false
        }
    }
}

//
//  PHAsset+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit
import Photos

extension PHAsset {
    
    var isLocallyAvailable: Bool {
        guard let resource = PHAssetResource.assetResources(for: self).first,
              let locallyAvailable = resource.value(forKey: "locallyAvailable") as? Bool else {
                  return false
              }
        return locallyAvailable
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

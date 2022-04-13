//
//  AssetSaveManager+SaveLivePhoto.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/11.
//

import UIKit
import Photos

public extension AssetSaveManager {
    
    static func saveLivePhoto(photoURL: URL, videoURL: URL, success: AssetSaveSuccess? = nil, failure: AssetSaveFailure? = nil) {
        var localIdentifier: String = ""
        let changes = {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: photoURL, options: nil)
            request.addResource(with: .pairedVideo, fileURL: videoURL, options: nil)
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier ?? ""
        }
        PHPhotoLibrary.shared().performChanges(changes) { _, _ in
            DispatchQueue.main.async {
                if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                    success?(asset)
                } else {
                    failure?()
                }
            }
        }
    }
    
}

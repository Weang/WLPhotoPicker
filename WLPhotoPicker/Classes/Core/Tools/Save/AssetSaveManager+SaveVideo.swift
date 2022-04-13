//
//  AssetSaveManager+SaveVideo.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/4.
//

import UIKit
import Photos

extension AssetSaveManager {
    
    static func saveVideo(videoURL: URL, success: AssetSaveSuccess? = nil, failure: AssetSaveFailure? = nil) {
        var localIdentifier: String = ""
        let changes = {
            guard let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL) else {
                failure?()
                return
            }
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

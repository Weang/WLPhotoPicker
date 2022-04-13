//
//  AssetSaveManager+SavePhoto.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/3.
//

import UIKit
import Photos

extension AssetSaveManager {
    
    static func savePhoto(photo: UIImage, success: AssetSaveSuccess? = nil, failure: AssetSaveFailure? = nil) {
        var localIdentifier: String = ""
        let changes = {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: photo)
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

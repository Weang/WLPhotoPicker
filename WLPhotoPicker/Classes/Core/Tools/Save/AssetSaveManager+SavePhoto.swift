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
        PHPhotoLibrary.shared().performChanges(changes) { _, error in
            DispatchQueue.main.async {
                if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                    success?(asset)
                } else {
                    failure?(error)
                }
            }
        }
    }
    
    static func savePhoto(photoURL: URL, success: AssetSaveSuccess? = nil, failure: AssetSaveFailure? = nil) {
        var localIdentifier: String = ""
        let changes = {
            guard let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: photoURL) else {
                failure?(nil)
                return
            }
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier ?? ""
        }
        PHPhotoLibrary.shared().performChanges(changes) { _, error in
            DispatchQueue.main.async {
                if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                    success?(asset)
                } else {
                    failure?(error)
                }
            }
        }
    }
}

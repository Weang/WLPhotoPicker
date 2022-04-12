//
//  AssetSaveManager+SaveVideo.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/4.
//

import UIKit
import Photos

extension AssetSaveManager {
    
    static func saveVideo(url: URL, completion: AssetSaveCompletion? = nil) {
        var localIdentifier: String = ""
        let changes = {
            guard let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) else {
                completion?(.failure(.invalidVideoURL))
                return
            }
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier ?? ""
        }
        PHPhotoLibrary.shared().performChanges(changes) { _, _ in
            DispatchQueue.main.async {
                if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                    completion?(.success(asset))
                } else {
                    completion?(.failure(.saveVideoFailed))
                }
            }
        }
    }
    
}

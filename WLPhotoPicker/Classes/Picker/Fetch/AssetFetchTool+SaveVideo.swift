//
//  AssetFetchTool+SaveVideo.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/4.
//

import UIKit
import Photos

public typealias SaveVideoCompletion = (Result<PHAsset, AssetSaveError>) -> Void

extension AssetFetchTool {
    
    public static func saveVideo(url: URL, completion: @escaping SaveVideoCompletion) {
        var localIdentifier: String = ""
        let changes = {
            guard let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) else {
                completion(.failure(.invalidPhoto))
                return
            }
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier ?? ""
        }
        PHPhotoLibrary.shared().performChanges(changes) { _, _ in
            DispatchQueue.main.async {
                if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                    completion(.success(asset))
                } else {
                    completion(.failure(.savePhotoFailed))
                }
            }
        }
    }
    
}

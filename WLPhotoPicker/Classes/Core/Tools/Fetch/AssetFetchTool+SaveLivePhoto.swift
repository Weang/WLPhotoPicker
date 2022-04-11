//
//  AssetFetchTool+SaveLivePhoto.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/11.
//

import UIKit
import Photos

typealias SaveLivePhotoCompletion = (Result<PHAsset, AssetSaveError>) -> Void

extension AssetFetchTool {
    
    static func saveLivePhoto(livePhoto: PHLivePhoto, completion: @escaping SaveLivePhotoCompletion) {
        let results = PHAssetResource.assetResources(for: livePhoto)
        guard let photoResource = results.first(where: { $0.type == .photo }),
              let pairedVideoResource = results.first(where: { $0.type == .pairedVideo }) else {
            completion(.failure(.saveLivePhotoFailed))
            return
        }
        let filePath = FileHelper.createLivePhotoPath()
        let photoURL = URL(fileURLWithPath: filePath.imagePath)
        let videoURL = URL(fileURLWithPath: filePath.videoPath)
        
        let manager = PHAssetResourceManager.default()
        manager.writeData(for: photoResource, toFile: photoURL, options: nil) { photoWriteError in
            
            if photoWriteError != nil {
                completion(.failure(.saveLivePhotoFailed))
                return
            }
            manager.writeData(for: pairedVideoResource, toFile: videoURL, options: nil) { videoWriteError in
                if videoWriteError != nil {
                    completion(.failure(.saveLivePhotoFailed))
                    return
                } else {
                    saveLivePhoto(photoURL: photoURL, videoURL: videoURL, completion: completion)
                }
            }
        }
    }
    
    static func saveLivePhoto(photoURL: URL, videoURL: URL, completion: @escaping SaveLivePhotoCompletion) {
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
                    completion(.success(asset))
                } else {
                    completion(.failure(.saveLivePhotoFailed))
                }
            }
        }
    }
    
}

//
//  AssetFetchTool+Photo.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/15.
//

import UIKit
import Photos

public typealias LocalPhotoFetchCompletion = (Result<LocalPhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    public static func requestPhoto(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping LocalPhotoFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.imageVersion
        requestOptions.resizeMode = options.imageResizeMode
        requestOptions.isSynchronous = options.isSynchronous
        requestOptions.deliveryMode = options.imageDeliveryMode
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        let targetSize = options.targetSizeWith(asset: asset)
        
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: requestOptions) { image, info in
            let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID ?? 0
            
            do {
                try handleInfo(info)
            } catch let error as AssetFetchError {
                completion(.failure(error), requestID)
                return
            } catch let error {
                completion(.failure(.underlying(error)), requestID)
                return
            }
            
            guard let image = image else {
                completion(.failure(.fetchFailed), requestID)
                return
            }
            
            let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            let response = LocalPhotoFetchResponse(image: image, isDegraded: isDegraded)
            completion(.success(response), requestID)
            
        }
    }
    
}

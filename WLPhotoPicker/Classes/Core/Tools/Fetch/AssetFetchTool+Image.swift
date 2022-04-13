//
//  AssetFetchTool+Image.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/15.
//

import UIKit
import Photos

typealias LocalPhotoFetchCompletion = (Result<PhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    static func requestPhoto(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping LocalPhotoFetchCompletion) -> AssetFetchRequest {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.imageVersion
        requestOptions.resizeMode = options.imageResizeMode
        requestOptions.isSynchronous = options.isSynchronous
        requestOptions.deliveryMode = options.imageDeliveryMode
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        let targetSize = options.targetSizeWith(assetSize: asset.pixelSize)
        
        let requestId = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: requestOptions) { photo, info in
            DispatchQueue.main.async {
                let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID ?? 0
                
                if let error = catchInfoError(info) {
                    completion(.failure(error), requestID)
                    return
                }
                
                guard let photo = photo else {
                    completion(.failure(.failedToFetchPhoto), requestID)
                    return
                }
                
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                let response = PhotoFetchResponse(photo: photo, isDegraded: isDegraded)
                completion(.success(response), requestID)
            }
        }
        
        return AssetFetchRequest(requestId: requestId)
    }
    
}

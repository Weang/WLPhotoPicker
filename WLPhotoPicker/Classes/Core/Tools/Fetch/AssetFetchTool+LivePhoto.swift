//
//  AssetFetchTool+LivePhoto.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos

typealias LivePhotoFetchCompletion = (Result<LivePhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    static func requestLivePhoto(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping LivePhotoFetchCompletion) -> AssetFetchRequest {
        let requestOptions = PHLivePhotoRequestOptions()
        requestOptions.version = options.imageVersion
        requestOptions.deliveryMode = options.imageDeliveryMode
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        let targetSize = options.targetSizeWith(assetSize: asset.pixelSize)
        
        let requestId = PHImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .default, options: requestOptions) { livePhoto, info in
            DispatchQueue.main.async {
                let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID ?? 0
                
                if let error = catchInfoError(info) {
                    completion(.failure(error), requestID)
                    return
                }
                
                guard let livePhoto = livePhoto else {
                    completion(.failure(.failedToFetchLivePhoto), requestID)
                    return
                }
                
                let response = LivePhotoFetchResponse(livePhoto: livePhoto)
                completion(.success(response), requestID)
            }
        }
        
        return AssetFetchRequest(requestId: requestId)
    }
    
}

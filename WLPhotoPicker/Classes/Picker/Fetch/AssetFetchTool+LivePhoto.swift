//
//  AssetFetchTool+LivePhoto.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos

public typealias LivePhotoFetchCompletion = (Result<LivePhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    public static func requestLivePhoto(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping LivePhotoFetchCompletion) -> AssetFetchRequest {
        
        let requestOptions = PHLivePhotoRequestOptions()
        requestOptions.version = options.imageVersion
        requestOptions.deliveryMode = options.imageDeliveryMode
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        let targetSize = options.targetSizeWith(asset: asset)
        
        let requestId = PHImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { livePhoto, info in
            DispatchQueue.main.async {
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
                
                guard let livePhoto = livePhoto else {
                    completion(.failure(.fetchFailed), requestID)
                    return
                }
                
                let response = LivePhotoFetchResponse(livePhoto: livePhoto)
                completion(.success(response), requestID)
            }
        }
        let request = AssetFetchRequest()
        request.appendRequestId(requestId)
        return request
    }
    
}

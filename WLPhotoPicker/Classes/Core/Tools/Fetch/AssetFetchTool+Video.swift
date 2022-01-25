//
//  AssetFetchTool+Video.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos

typealias VideoFetchCompletion = (Result<VideoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    static func requestAVAsset(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping VideoFetchCompletion) -> AssetFetchRequest {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = options.videoVersion
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.deliveryMode = options.videoDeliveryMode
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        let request = AssetFetchRequest()
        
        if let fileURL = asset.locallyVideoFileURL {
            let avasset = AVAsset(url: fileURL)
            let playerItem = AVPlayerItem(asset: avasset)
            DispatchQueue.main.async {
                completion(.success(VideoFetchResponse(avasset: avasset, playerItem: playerItem)), 0)
            }
            return request
        }
        
        if !asset.isVideoLocallyAvailable {
            DispatchQueue.main.async {
                options.progressHandler?(0)
            }
        }
        
        let requestId = PHImageManager.default().requestAVAsset(forVideo: asset, options: requestOptions) { (avAsset, _, info) in
            DispatchQueue.main.async {
                let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID ?? 0
                
                if let error = handleInfo(info) {
                    completion(.failure(error), requestID)
                    return
                }
                
                guard let avAsset = avAsset else {
                    completion(.failure(.failedToLoadVideo), requestID)
                    return
                }
                
                let response = VideoFetchResponse(avasset: avAsset, playerItem: AVPlayerItem(asset: avAsset))
                completion(.success(response), requestID)
            }
        }
        request.appendRequestId(requestId)
        return request
    }
    
}

//
//  AssetFetchTool+ImageData.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos

typealias CloudPhotoFetchCompletion = (Result<CloudPhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    static func requestImageData(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping CloudPhotoFetchCompletion) -> AssetFetchRequest {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.imageVersion
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        let requestId: PHImageRequestID
        
        if #available(iOS 13.0, *) {
            requestId = PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, dataUTI, _, info) in
                handleResponse(data: data, dataUTI: dataUTI, info: info, completion: completion)
            }
        } else {
            requestId = PHImageManager.default().requestImageData(for: asset, options: requestOptions) { (data, dataUTI, _, info) in
                handleResponse(data: data, dataUTI: dataUTI, info: info, completion: completion)
            }
        }
        
        return AssetFetchRequest(requestId: requestId)
    }
    
    private static func handleResponse(data: Data?, dataUTI: String?, info: [AnyHashable: Any]?, completion: @escaping CloudPhotoFetchCompletion) {
        DispatchQueue.main.async {
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            
            if let error = catchInfoError(info) {
                completion(.failure(error), requestID)
                return
            }
            
            guard let dataUTI = dataUTI, let data = data else {
                completion(.failure(.failedToFetchPhoto), requestID)
                return
            }
            
            let response = CloudPhotoFetchResponse(data: data, dataUTI: dataUTI)
            completion(.success(response), requestID)
        }
    }
    
}

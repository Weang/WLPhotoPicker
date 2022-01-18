//
//  AssetFetchTool+PhotoData.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos

public typealias CloudPhotoFetchCompletion = (Result<CloudPhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    public static func requestImageData(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping CloudPhotoFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.imageVersion
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = { progress, _, _, _ in
            options.progressHandler?(progress)
        }
        
        func handleResponse(data: Data?, dataUTI: String?, info: [AnyHashable: Any]?, completion: @escaping CloudPhotoFetchCompletion) {
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            
            do {
                try handleInfo(info)
            } catch let error as AssetFetchError {
                completion(.failure(error), requestID)
                return
            } catch let error {
                completion(.failure(.underlying(error)), requestID)
                return
            }
            
            guard let dataUTI = dataUTI, let data = data else {
                completion(.failure(.fetchFailed), requestID)
                return
            }
            
            let response = CloudPhotoFetchResponse(data: data, dataUTI: dataUTI)
            completion(.success(response), requestID)
        }
        
        let manager = PHImageManager.default()
        
        if #available(iOS 13.0, *) {
            return manager.requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, dataUTI, orientation, info) in
                handleResponse(data: data, dataUTI: dataUTI, info: info, completion: completion)
            }
        } else {
            return manager.requestImageData(for: asset, options: requestOptions) { (data, dataUTI, uiOrientation, info) in
                handleResponse(data: data, dataUTI: dataUTI, info: info, completion: completion)
            }
        }
    }
    
}

//
//  AssetFetchTool+GIF.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos
import MobileCoreServices

typealias GIFPhotoFetchCompletion = (Result<GIFFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    static let GIFGeneratorQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.AssetFetchTool.GIFGenerator")
    
    @discardableResult
    static func requestGIF(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping GIFPhotoFetchCompletion) -> AssetFetchRequest {
        
        func handleResult(_ result: Result<GIFFetchResponse, AssetFetchError>, requestId: PHImageRequestID) {
            DispatchQueue.main.async {
                completion(result, requestId)
            }
        }
        
        return requestImageData(for: asset, options: options) { result, requestId in
            switch result {
            case .success(let response):
                GIFGeneratorQueue.async {
                    if let image = GIFGenerator.animatedImageWith(data: response.data) {
                        handleResult(.success(GIFFetchResponse(image: image, imageData: response.data)), requestId: requestId)
                    } else {
                        handleResult(.failure(.failedToLoadImage), requestId: requestId)
                    }
                }
            case .failure(let error):
                handleResult(.failure(error), requestId: requestId)
            }
        }
    }
    
}

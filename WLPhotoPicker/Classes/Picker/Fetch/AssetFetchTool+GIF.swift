//
//  AssetFetchTool+GIF.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/20.
//

import Photos
import MobileCoreServices

public typealias GIFPhotoFetchCompletion = (Result<GIFFetchResponse, AssetFetchError>, PHImageRequestID) -> Void

extension AssetFetchTool {
    
    @discardableResult
    public static func requestGIF(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping GIFPhotoFetchCompletion) -> AssetFetchRequest {
        let requestId = requestImageData(for: asset, options: options) { result, requestId in
            switch result {
            case .success(let response):
                guard UTTypeConformsTo(response.dataUTI as CFString, kUTTypeGIF) else {
                    completion(.failure(.faildToDecodeGIF), requestId)
                    return
                }
                imageHelperQueue.async {
                    if let image = GIFGenerator.animatedImageWith(data: response.data) {
                        DispatchQueue.main.async {
                            completion(.success(GIFFetchResponse(image: image, imageData: response.data)), requestId)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.faildToDecodeGIF), requestId)
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error), requestId)
            }
        }
        let request = AssetFetchRequest()
        request.appendRequestId(requestId)
        return request
    }
    
}

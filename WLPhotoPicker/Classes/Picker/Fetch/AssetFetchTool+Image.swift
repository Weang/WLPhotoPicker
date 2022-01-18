//
//  AssetFetchTool+Image.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/17.
//

import Photos

public typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, AssetFetchError>, PHImageRequestID) -> Void
public typealias ImageConvertCompletion = (UIImage?) -> Void

extension AssetFetchTool {
    
    static let imageHelperQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.AssetFetchTool.ImageHelper")
    
    @discardableResult
    public static func requestImage(for asset: PHAsset, options: AssetFetchOptions, completion: @escaping PhotoFetchCompletion) -> AssetFetchRequest {
        let request = AssetFetchRequest()
        
        let requestId = requestPhoto(for: asset, options: options) { result, requestId in
            switch result {
            case .success(let response):
                let photoResponse = PhotoFetchResponse(image: response.image, isDegraded: response.isDegraded)
                completion(.success(photoResponse), requestId)
            case .failure(let error):
                guard case .cannotFindInLocal = error else {
                    completion(.failure(error), requestId)
                    return
                }
                let requestId = self.requestImageData(for: asset, options: options, completion: { result, requestId in
                    switch result {
                    case .success(let response):
                        self.convert(imageData: response.data, with: options, requestId: requestId, completion: { image in
                            if let image = image {
                                let photoResponse = PhotoFetchResponse(image: image, isDegraded: false)
                                completion(.success(photoResponse), requestId)
                            } else {
                                completion(.failure(.faildToDecodeImage), requestId)
                            }
                        })
                    case .failure(let error):
                        completion(.failure(error), requestId)
                    }
                })
                request.appendRequestId(requestId)
            }
        }
        request.appendRequestId(requestId)
        return request
    }
    
    public static func convert(imageData: Data, with options: AssetFetchOptions, requestId: PHImageRequestID, completion: @escaping ImageConvertCompletion) {
        imageHelperQueue.async {
            let image: UIImage?
            switch options.sizeOption {
            case .original:
                image = UIImage(data: imageData)
            case .specify(let size):
                image = ImageGenerator.resizeImage(from: imageData, targetSize: size)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
}

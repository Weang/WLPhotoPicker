//
//  AssetFetchRequest.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import Photos

// 图片请求request对象
public class AssetFetchRequest {
    
    private var requestIds: [PHImageRequestID] = []
    
    public func appendRequestId(_ requestId: PHImageRequestID) {
        requestIds.append(requestId)
    }
    
    public func containsRequestId(_ requestId: PHImageRequestID) -> Bool {
        requestIds.contains(requestId)
    }
    
    public func cancel() {
        requestIds.forEach {
            PHImageManager.default().cancelImageRequest($0)
        }
    }
    
}

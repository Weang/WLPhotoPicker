//
//  AssetFetchRequest.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import Photos

// 图片请求request对象
public class AssetFetchRequest {
    
    private let requestId: PHImageRequestID
    
    init(requestId: PHImageRequestID) {
        self.requestId = requestId
    }
    
    public func requestIdIs(_ requestId: PHImageRequestID) -> Bool {
        requestId == requestId
    }
    
    public func cancel() {
        PHImageManager.default().cancelImageRequest(requestId)
    }
    
}

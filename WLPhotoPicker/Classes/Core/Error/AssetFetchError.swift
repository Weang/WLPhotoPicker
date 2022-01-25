//
//  AssetFetchError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/21.
//

import UIKit

public enum AssetFetchError: Error {
    // normal
    case invalidInfo
    case canceled
    case cannotFindInLocal
    
    // image
    case failedToLoadImage
    
    // video
    case failedToLoadVideo
    
    // other
    case underlying(Error)
}

extension AssetFetchError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidInfo:
            return "文件加载失败"
        case .canceled:
            return "下载已取消"
        case .cannotFindInLocal:
            return "未找到本地资源"
        case .failedToLoadImage:
            return "无法加载图片"
        case .failedToLoadVideo:
            return "无法加载视频"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

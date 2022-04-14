//
//  AssetFetchError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/21.
//

import UIKit

public enum AssetFetchError: Error {
    // Fetch
    case invalidInfo
    case canceled
    case failedToFetchPhoto
    case failedToFetchGIF
    case failedToFetchLivePhoto
    case failedToFetchVideo
    
    // Export
    case failedToExportPhoto
    case failedToExportVideo
    
    // Other
    case underlying(Error)
}

extension AssetFetchError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidInfo:
            return "无法加载资源文件"
        case .canceled:
            return "已取消"
        case .failedToFetchPhoto:
            return "无法加载图片资源"
        case .failedToFetchGIF:
            return "无法加载图片资源"
        case .failedToFetchLivePhoto:
            return "无法加载实况照片资源"
        case .failedToFetchVideo:
            return "无法加载视频资源"
        case .failedToExportPhoto:
            return "无法导出选择的照片"
        case .failedToExportVideo:
            return "无法导出选择的视频"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

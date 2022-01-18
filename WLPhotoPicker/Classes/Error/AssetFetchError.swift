//
//  AssetFetchError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/21.
//

import UIKit

public enum AssetFetchError: Error {
    // normal
    case canceled
    case fetchFailed
    case cannotFindInLocal
    
    // image
    case faildToDecodeImage
    case faildToDecodeGIF
    
    // video
    case invalidVideoUrl
    case invalidVideoPreset
    case invalidVideoFileType
    
    // other
    case underlying(Error)
}

extension AssetFetchError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "资源下载已取消"
        case .fetchFailed:
            return "资源下载失败"
        case .cannotFindInLocal:
            return "未找到本地资源"
        case .faildToDecodeImage, .faildToDecodeGIF:
            return "资源加载失败"
        case .invalidVideoUrl:
            return "视频存储路径错误"
        case .invalidVideoPreset:
            return "设备不支持视频预设"
        case .invalidVideoFileType:
            return "视频格式不支持导出"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

//
//  VideoExportError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import UIKit

public enum VideoCompressError: Error {
    case failedToLoadAsset
    case failedToWriteAsset
    case underlying(Error)
}

extension VideoCompressError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .failedToLoadAsset:
            return "读取视频文件失败"
        case .failedToWriteAsset:
            return "写入视频文件失败"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

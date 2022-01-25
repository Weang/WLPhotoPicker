//
//  WLPhotoError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

public enum WLPhotoError: Error {
    
    // 请求错误
    case fetchError(AssetFetchError)
    
    // 视频导出错误
    case videoCompressError(VideoCompressError)
    
    // 文件写入错误
    case fileHelper(FileError)
    
    // 相机拍摄错误
    case captureError(CaptureError)
    
}

extension WLPhotoError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .fetchError(let error):
            return error.localizedDescription
        case .captureError(let error):
            return error.localizedDescription
        case .fileHelper(let error):
            return error.localizedDescription
        case .videoCompressError:
            return "视频导出错误"
        }
    }
}

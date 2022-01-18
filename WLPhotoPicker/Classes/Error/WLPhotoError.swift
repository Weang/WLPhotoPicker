//
//  WLPhotoError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

public enum WLPhotoError: Error {
    
    // 图片请求错误
    case fetchError(AssetFetchError)
    
    // 相机拍摄错误
    case captureError(CaptureError)
    
    // 文件写入错误
    case fileHelper(FileError)
    
    // 视频导出错误
    case videoExportError(VideoExportError)
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
        case .videoExportError:
            return "视频导出错误"
        }
    }
}

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
            return BundleHelper.localizedString(.FailedToLoadAsset)
        case .failedToWriteAsset:
            return BundleHelper.localizedString(.FailedToWriteAsset)
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

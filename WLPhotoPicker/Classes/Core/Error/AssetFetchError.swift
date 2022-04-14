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
            return BundleHelper.localizedString(.InvalidInfo)
        case .canceled:
            return BundleHelper.localizedString(.Canceled)
        case .failedToFetchPhoto:
            return BundleHelper.localizedString(.FailedToFetchPhoto)
        case .failedToFetchGIF:
            return BundleHelper.localizedString(.FailedToFetchGIF)
        case .failedToFetchLivePhoto:
            return BundleHelper.localizedString(.FailedToFetchLivePhoto)
        case .failedToFetchVideo:
            return BundleHelper.localizedString(.FailedToFetchVideo)
        case .failedToExportPhoto:
            return BundleHelper.localizedString(.FailedToExportPhoto)
        case .failedToExportVideo:
            return BundleHelper.localizedString(.FailedToExportVideo)
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

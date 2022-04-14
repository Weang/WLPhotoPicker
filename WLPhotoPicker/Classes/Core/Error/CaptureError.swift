//
//  CaptureError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit

public enum CaptureError {
    case failedToInitializeCameraDevice
    case failedToInitializeMicrophoneDevice
    case underlying(Error)
}

extension CaptureError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .failedToInitializeCameraDevice:
            return BundleHelper.localizedString(.FailedToInitializeCameraDevice)
        case .failedToInitializeMicrophoneDevice:
            return BundleHelper.localizedString(.FailedToInitializeMicrophoneDevice)
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

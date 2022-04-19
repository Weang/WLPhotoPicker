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
    case cameraPermissionDenied
    case microphonePermissionDenied
    case underlying(Error)
}

extension CaptureError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .failedToInitializeCameraDevice:
            return BundleHelper.localizedString(.FailedToInitializeCameraDevice)
        case .failedToInitializeMicrophoneDevice:
            return BundleHelper.localizedString(.FailedToInitializeMicrophoneDevice)
        case .cameraPermissionDenied:
            return BundleHelper.localizedString(.CameraPermissionDenied, UIApplication.shared.appName ?? "")
        case .microphonePermissionDenied:
            return BundleHelper.localizedString(.MicrophonePermissionDenied, UIApplication.shared.appName ?? "")
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

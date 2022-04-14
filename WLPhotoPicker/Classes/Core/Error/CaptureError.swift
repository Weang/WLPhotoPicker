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
            return "相机初始化失败"
        case .failedToInitializeMicrophoneDevice:
            return "麦克风初始化失败"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

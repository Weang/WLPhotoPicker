//
//  CaptureError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit

public enum CaptureError {
    case simulator
    case failedToInitializeCameraDevice
    case failedToInitializeAudioDevice
    case underlying(Error)
}

extension CaptureError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .simulator:
            return "模拟器不支持拍摄"
        case .failedToInitializeCameraDevice:
            return "设备初始化失败"
        case .failedToInitializeAudioDevice:
            return "设备初始化失败"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
    
}

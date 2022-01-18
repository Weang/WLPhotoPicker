//
//  CaptureError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit

public enum CaptureError {
    
    case simulator
    case deviceInitializeError
    case fileWriteError
    case changeCameraFailed
    
}

extension CaptureError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .simulator:
            return "模拟器不支持拍摄"
        case .deviceInitializeError:
            return "设备初始化失败"
        case .fileWriteError:
            return "无法写入文件"
        case .changeCameraFailed:
            return "无法切换摄像头"
        }
    }
    
}

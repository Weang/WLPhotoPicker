//
//  CaptureFlashMode.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import AVFoundation

// 拍摄闪光灯选项
public enum CaptureFlashMode {
    case auto
    case on
    case off
}

extension CaptureFlashMode {
    
    var avFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .auto: return .auto
        case .on: return .on
        case .off: return .off
        }
    }
    
    var cameraFlashMode: UIImagePickerController.CameraFlashMode {
        switch self {
        case .auto: return .auto
        case .on: return .on
        case .off: return .off
        }
    }
    
}

//
//  CaptureSessionPreset.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import AVFoundation

public enum CaptureSessionPreset {
    case cif352x288
    case vga640x480
    case hd1280x720
    case hd1920x1080
    case hd4K3840x2160
}

extension CaptureSessionPreset {
    
    var avSessionPreset: AVCaptureSession.Preset {
        switch self {
        case .cif352x288: return .cif352x288
        case .vga640x480: return .vga640x480
        case .hd1280x720: return .hd1280x720
        case .hd1920x1080: return .hd1920x1080
        case .hd4K3840x2160: return .hd4K3840x2160
        }
    }
    
    var size: CGSize {
        switch self {
        case .cif352x288: return CGSize(width: 352, height: 288)
        case .vga640x480: return CGSize(width: 640, height: 480)
        case .hd1280x720: return CGSize(width: 1280, height: 720)
        case .hd1920x1080: return CGSize(width: 1920, height: 1080)
        case .hd4K3840x2160: return CGSize(width: 3840, height: 2160)
        }
    }
}

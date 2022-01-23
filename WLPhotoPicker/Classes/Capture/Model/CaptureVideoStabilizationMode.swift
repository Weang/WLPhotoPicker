//
//  CaptureVideoStabilizationMode.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/4.
//

import UIKit
import AVFoundation

public enum CaptureVideoStabilizationMode {
    case auto
    case off
    case standard
    case cinematic
    @available(iOS 13.0, *)
    case cinematicExtended
}

extension CaptureVideoStabilizationMode {
    
    var avPreferredVideoStabilizationMode: AVCaptureVideoStabilizationMode {
        switch self {
        case .auto: return .auto
        case .off: return .off
        case .standard: return .standard
        case .cinematic: return .cinematic
        case .cinematicExtended:
            if #available(iOS 13.0, *) {
                return .cinematicExtended
            }
            return .auto
        }
    }
    
}


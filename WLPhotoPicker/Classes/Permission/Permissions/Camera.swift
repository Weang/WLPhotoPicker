//
//  Camera.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import AVFoundation

struct Camera: Permission {
    
    static var status: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:       return .authorized
        case .denied:           return .denied
        case .notDetermined:    return .notDetermined
        case .restricted:       return .restricted
        @unknown default:       return .invalid
        }
    }
    
    static func requestPermission(_ closure: @escaping (PermissionStatus) -> ()) {
        guard status == .notDetermined else {
            closure(status)
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { _ in
            closure(self.status)
        }
    }
    
}

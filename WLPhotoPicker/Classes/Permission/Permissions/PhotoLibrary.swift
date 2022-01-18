//
//  PhotoLibrary.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import Photos

struct PhotoLibrary: Permission {
    
    static var status: PermissionStatus {
        let status: PHAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        switch status {
        case .authorized:       return .authorized
        case .denied:           return .denied
        case .notDetermined:    return .notDetermined
        case .restricted:       return .restricted
        case .limited:          return .limited
        @unknown default:       return .invalid
        }
    }
    
    static func requestPermission(_ closure: @escaping (PermissionStatus) -> ()) {
        guard status == .notDetermined else {
            closure(status)
            return
        }
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                closure(status)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { _ in
                closure(status)
            }
        }
    }
}

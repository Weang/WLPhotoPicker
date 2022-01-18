//
//  PermissionType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import Foundation

enum PermissionType {
    case photoLibrary
    case microphone
    case camera
}

extension PermissionType {
    
    public var displayText: String {
        switch self {
        case .photoLibrary: return "相册"
        case .camera: return "相机"
        case .microphone: return "麦克风"
        }
    }
    
    public var permission: Permission.Type {
        switch self {
        case .photoLibrary: return PhotoLibrary.self
        case .camera: return Camera.self
        case .microphone: return Microphone.self
        }
    }
    
}

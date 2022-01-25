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
    
    public var permission: Permission.Type {
        switch self {
        case .photoLibrary: return PhotoLibrary.self
        case .camera: return Camera.self
        case .microphone: return Microphone.self
        }
    }
    
}

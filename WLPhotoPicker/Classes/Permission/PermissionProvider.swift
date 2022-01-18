//
//  PermissionProvider.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

struct PermissionProvider {
    
    public static func statusFor(_ type: PermissionType) -> PermissionStatus {
        return type.permission.status
    }
    
    public static func request(_ type: PermissionType, completion: @escaping (PermissionStatus) -> () = {_ in }) {
        func handleStatus(_ status: PermissionStatus) {
            DispatchQueue.main.async {
                completion(status)
            }
        }
        
        if type.permission.status == .notDetermined {
            type.permission.requestPermission { status in
                handleStatus(status)
            }
        } else {
            handleStatus(type.permission.status)
        }
        
    }
    
}

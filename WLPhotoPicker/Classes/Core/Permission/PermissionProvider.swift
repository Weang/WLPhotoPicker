//
//  PermissionProvider.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

typealias PermissionProviderCompletion = (PermissionType, PermissionStatus) -> Void

struct PermissionProvider {
    
    public static func statusFor(_ type: PermissionType) -> PermissionStatus {
        return type.permission.status
    }
    
    public static func request(_ type: PermissionType, completion: @escaping PermissionProviderCompletion = {_,_  in }) {
        func handleStatus(_ status: PermissionStatus) {
            DispatchQueue.main.async {
                completion(type, status)
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
    
    public static func request(_ types: [PermissionType], completion: @escaping PermissionProviderCompletion = {_,_  in }) {
        request(types[0]) { type, status in
            if status == .authorized || status == .limited {
                if types.count > 1 {
                    var types = types
                    types.remove(at: 0)
                    request(types, completion: completion)
                } else {
                    completion(type, status)
                }
                
            } else {
                completion(type, status)
            }
        }
    }
    
}

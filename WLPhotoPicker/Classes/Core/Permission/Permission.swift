//
//  Permission.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

protocol Permission {
    static var isAuthorized: Bool { get }
    static var status: PermissionStatus { get }
    static func requestPermission(_ closure: @escaping (PermissionStatus) -> ())
}

extension Permission {
    
    static var isAuthorized: Bool {
        return status == .authorized
    }
    
}

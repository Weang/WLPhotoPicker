//
//  PermissionStatus.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case invalid
    case limited
    case restricted
    
    var description: String {
        switch self {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .notDetermined: return "Not Determined"
        case .invalid: return "Invalid"
        case .limited: return "Limited"
        case .restricted: return "Restricted"
        }
    }
}

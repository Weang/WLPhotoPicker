//
//  Microphone.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import AVFoundation

class Microphone: Permission {
    
    static var status: PermissionStatus {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .granted: return .authorized
        case .undetermined: return .notDetermined
        case .denied: return .denied
        @unknown default: return .invalid
        }
    }
    
    static func requestPermission(_ closure: @escaping (PermissionStatus) -> ()) {
        guard status == .notDetermined else {
            closure(status)
            return
        }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            closure(status)
        }
    }
}

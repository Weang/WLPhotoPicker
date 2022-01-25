//
//  DeviceOrientation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import CoreMotion
import AVFoundation

protocol DeviceOrientationDelegate: AnyObject {
    func deviceOrientation(_ deviceOrientation: DeviceOrientation, didUpdate orientation: AVCaptureVideoOrientation)
}

class DeviceOrientation: NSObject {

    weak var delegate: DeviceOrientationDelegate?
    
    let motionManager = CMMotionManager()
    
    override init() {
        super.init()
        motionManager.deviceMotionUpdateInterval = 0.5
    }
    
    func startUpdates() {
        if motionManager.isDeviceMotionAvailable,
           let queue = OperationQueue.current {
            motionManager.startDeviceMotionUpdates(to: queue) { (motion, _) in
                self.deviceMotion(motion)
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func deviceMotion(_ motion: CMDeviceMotion?) {
        let sensitive = 0.77
        guard let motion = motion else {
            delegate?.deviceOrientation(self, didUpdate: .portrait)
            return
        }
        let x = motion.gravity.x
        let y = motion.gravity.y
        
        if y < 0 && fabs(y) > sensitive {
            delegate?.deviceOrientation(self, didUpdate: .portrait)
        } else if y > sensitive {
            delegate?.deviceOrientation(self, didUpdate: .portraitUpsideDown)
        }
        
        if x < 0 && fabs(x) > sensitive {
            delegate?.deviceOrientation(self, didUpdate: .landscapeRight)
        } else if x > sensitive {
            delegate?.deviceOrientation(self, didUpdate: .landscapeLeft)
        }
    }
    
}

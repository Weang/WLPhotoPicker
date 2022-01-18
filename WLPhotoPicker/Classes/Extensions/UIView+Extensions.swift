//
//  UIView+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import Foundation

var keyWindowSafeAreaInsets: UIEdgeInsets {
    UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
}

extension UIView {
    
    var x: CGFloat {
        get {
            frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var size: CGSize {
        get {
            bounds.size
        }
        set {
            frame.size = newValue
        }
    }
}

extension UIView {
    
    func screenShot() -> UIImage? {
        guard frame.size.height > 0 && frame.size.width > 0 else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

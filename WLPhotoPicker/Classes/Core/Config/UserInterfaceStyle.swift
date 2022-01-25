//
//  UserInterfaceStyle.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/24.
//

import UIKit

// 颜色配置
public enum UserInterfaceStyle {
    case auto
    case light
    case dark
}

extension UIColor {
    
    static func color(light: UIColor, dark: UIColor, style: UserInterfaceStyle) -> UIColor {
        switch style {
        case .auto:
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return dark
                    } else {
                        return light
                    }
                }
            } else {
                return light
            }
        case .light:
            return light
        case .dark:
            return dark
        }
    }
    
}

extension UIStatusBarStyle {
    
    static func statusBarStyle(style: UserInterfaceStyle) -> UIStatusBarStyle {
        switch style {
        case .auto:
            return .default
        case .light:
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        case .dark:
            return .lightContent
        }

    }

}

//
//  UserInterfaceStyle.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/24.
//

import UIKit

public enum UserInterfaceStyle {
    case light
    case dark
    case auto
}

extension UIColor {
    
    static func color(light: UIColor, dark: UIColor, style: UserInterfaceStyle) -> UIColor {
        switch style {
        case .light:
            return light
        case .dark:
            return dark
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
        }
    }
    
}

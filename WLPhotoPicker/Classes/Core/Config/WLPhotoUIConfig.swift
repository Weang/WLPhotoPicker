//
//  WLPhotoUIConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

// UI配置类
public class WLPhotoUIConfig {
    
    private init() { }
    
    public static let `default` = WLPhotoUIConfig()
    
    // 颜色配置，包括背景颜色，按钮颜色等
    public var color: ColorConfig = .default
    
    // 暗黑模式
    public var userInterfaceStyle: UserInterfaceStyle = .auto {
        didSet {
            color.userInterfaceStyle = userInterfaceStyle
        }
    }
}

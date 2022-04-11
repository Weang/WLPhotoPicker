//
//  WLPhotoUIConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

public class WLPhotoUIConfig {
    
    private init() { }
    
    public static let `default` = WLPhotoUIConfig()
    
    public var color: WLColorConfig = .default
    
    public var userInterfaceStyle: UserInterfaceStyle = .auto {
        didSet {
            color.userInterfaceStyle = userInterfaceStyle
        }
    }
}

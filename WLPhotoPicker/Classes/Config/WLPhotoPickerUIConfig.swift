//
//  WLPhotoPickerUIConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

public class WLPhotoPickerUIConfig {

    private init() { }
    
    public static let `default` = WLPhotoPickerUIConfig()
    
    // 按钮背景颜色、选中按钮颜色、预览底部缩略图边框颜色
    public var themeColor: UIColor = #colorLiteral(red: 0.1021535918, green: 0.676630497, blue: 0.1012429371, alpha: 1)
    
    // 通用文字、图标颜色
    public var textColor: UIColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    
    // 拍照、添加资源背景颜色
    public var functionItemBackgroundColor: UIColor = #colorLiteral(red: 0.8697023988, green: 0.8746746182, blue: 0.8831942677, alpha: 1)
}


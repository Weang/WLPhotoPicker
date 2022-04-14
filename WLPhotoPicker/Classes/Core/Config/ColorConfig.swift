//
//  WLColorConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/24.
//

import UIKit

public class ColorConfig {

    private init() { }
    
    static let `default` = ColorConfig()
    
    var userInterfaceStyle: UserInterfaceStyle = .auto
    
    // Picker 背景颜色
    public var pickerBackgroundLight = UIColor.white
    public var pickerBackgroundDark = #colorLiteral(red: 0.1960784197, green: 0.1960784197, blue: 0.1960783899, alpha: 1)
    var pickerBackground: UIColor {
        UIColor.color(light: pickerBackgroundLight, dark: pickerBackgroundDark, style: userInterfaceStyle)
    }
    
    // 相册列表背景颜色
    public var albumBackgroundLight = UIColor.white
    public var albumBackgroundDark = #colorLiteral(red: 0.1960784197, green: 0.1960784197, blue: 0.1960783899, alpha: 1)
    var albumBackground: UIColor {
        UIColor.color(light: pickerBackgroundLight, dark: pickerBackgroundDark, style: userInterfaceStyle)
    }
    
    // 导航栏背景颜色
    public var navigationBarColorLight = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    public var navigationBarColorDark = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    var navigationBarColor: UIColor {
        UIColor.color(light: navigationBarColorLight, dark: navigationBarColorDark, style: userInterfaceStyle)
    }
    
    // 底部工具栏背景颜色
    public var toolBarColorLight = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    public var toolBarColorDark = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    var toolBarColor: UIColor {
        UIColor.color(light: toolBarColorLight, dark: toolBarColorDark, style: userInterfaceStyle)
    }
    
    // 通用文字、图标颜色
    public var textColorLight = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    public var textColorDark = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    var textColor: UIColor {
        UIColor.color(light: textColorLight, dark: textColorDark, style: userInterfaceStyle)
    }
    
    // 按钮背景颜色、选中按钮颜色、预览底部缩略图边框颜色
    public var primaryColorLight = #colorLiteral(red: 0.1019607843, green: 0.6784313725, blue: 0.1019607843, alpha: 1)
    public var primaryColorDark = #colorLiteral(red: 0.06274509804, green: 0.6392156863, blue: 0.06274509804, alpha: 1)
    var primaryColor: UIColor {
        UIColor.color(light: primaryColorLight, dark: primaryColorDark, style: userInterfaceStyle)
    }
    
    // 拍照、添加资源背景颜色
    public var functionItemBackgroundColorLight = #colorLiteral(red: 0.8745098039, green: 0.8745098039, blue: 0.8745098039, alpha: 1)
    public var functionItemBackgroundColorDark = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    var functionItemBackgroundColor: UIColor {
        UIColor.color(light: functionItemBackgroundColorLight, dark: functionItemBackgroundColorDark, style: userInterfaceStyle)
    }
    
    // 拍照、添加资源图标文字颜色
    public var functionItemForegroundColorLight = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    public var functionItemForegroundColorDark = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    var functionItemForegroundColor: UIColor {
        UIColor.color(light: functionItemForegroundColorLight, dark: functionItemForegroundColorDark, style: userInterfaceStyle)
    }
    
    // 预览背景颜色
    public var previewBackgroundLight = UIColor.white
    public var previewBackgroundDark = UIColor.black
    var previewBackground: UIColor {
        UIColor.color(light: previewBackgroundLight, dark: previewBackgroundDark, style: userInterfaceStyle)
    }
    
    // Livephoto, iCloud加载背景颜色
    public var previewTipBackgroundLight = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    public var previewTipBackgroundDark = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
    var previewTipBackground: UIColor {
        UIColor.color(light: previewTipBackgroundLight, dark: previewTipBackgroundDark, style: userInterfaceStyle)
    }
    
}

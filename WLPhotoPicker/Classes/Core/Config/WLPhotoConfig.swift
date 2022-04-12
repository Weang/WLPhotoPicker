//
//  WLPhotoConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/11.
//

import UIKit

// Picker 配置类
public class WLPhotoConfig {
    
    public init() { }
    
    public static let `default` = WLPhotoConfig()
    
    // 照片选择参数
    public var pickerConfig = PickerConfig()
    
    // 照片编辑参数
    public var photoEditConfig = PhotoEditConfig()
    
    // 相机拍摄参数
    public var captureConfig = CaptureConfig()
    
}

public extension WLPhotoConfig {
    
    // 检测配置项
    func checkCongfig() -> WLPhotoConfig {
        if !pickerConfig.selectableType.contains(.photo) {
            captureConfig.captureAllowTakingPhoto = false
        }
        if !pickerConfig.selectableType.contains(.video) {
            captureConfig.captureAllowTakingVideo = false
        }
        return self
    }
    
}

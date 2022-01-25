//
//  WLPhotoConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/11.
//

import UIKit

public class WLPhotoConfig {
    
    public init() { }
    
    public static let `default` = WLPhotoConfig()
    
    public var pickerConfig = PickerConfig()
    
    public var photoEditConfig = PhotoEditConfig()
    
    public var captureConfig = CaptureConfig()
    
}

public extension WLPhotoConfig {
    
    var showCameraItem: Bool {
        captureConfig.captureAllowTakingPhoto || captureConfig.captureAllowTakingVideo
    }
    
    // 检测配置项
    func checkCongfig() -> WLPhotoConfig {
        if !pickerConfig.selectableType.contains(.photo) {
            captureConfig.captureAllowTakingPhoto = false
        }
        if !pickerConfig.selectableType.contains(.video) {
            captureConfig.captureAllowTakingVideo = false
        }
        if pickerConfig.allowEditPhoto {
            pickerConfig.allowEditPhoto = photoEditConfig.photoEditItemTypes.count > 0
        }
        if photoEditConfig.photoEditGraffitiColors.count == 0 {
            photoEditConfig.photoEditItemTypes.removeAll(where: { $0 == .graffiti })
        }
        if photoEditConfig.photoEditPasters.count == 0 {
            photoEditConfig.photoEditItemTypes.removeAll(where: { $0 == .paster })
        }
        if photoEditConfig.photoEditTextColors.count == 0 {
            photoEditConfig.photoEditItemTypes.removeAll(where: { $0 == .text })
        }
        if photoEditConfig.photoEditFilters.count == 0 {
            photoEditConfig.photoEditItemTypes.removeAll(where: { $0 == .filter })
        }
        if photoEditConfig.photoEditAdjustModes.count == 0 {
            photoEditConfig.photoEditItemTypes.removeAll(where: { $0 == .adjust })
        }
        return self
    }
    
}

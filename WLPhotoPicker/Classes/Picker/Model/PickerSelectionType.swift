//
//  PhotoPickerSelectionType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

// 可选择资源类型
public struct PickerSelectionType: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    // 照片，GIF、实况都处理为静态图片
    static public let photo = PickerSelectionType(rawValue: 1 << 0)
    
    // 视频
    static public let video = PickerSelectionType(rawValue: 1 << 1)
    
    // 动图
    static public let GIF = PickerSelectionType(rawValue: 1 << 2)
    
    // 实况
    static public let livePhoto = PickerSelectionType(rawValue: 1 << 3)
    
    // 所有类型
    static public let all: PickerSelectionType = [.photo, .video, .GIF, .livePhoto]
    
}

public extension PickerSelectionType {
    
    var hasPhoto: Bool {
        return contains(.photo) || contains(.GIF) || contains(.livePhoto)
    }
    
    var hasVideo: Bool {
        return contains(.video)
    }
    
    var isAll: Bool {
        return contains(.photo) && contains(.GIF) && contains(.livePhoto) && contains(.video)
    }
    
}

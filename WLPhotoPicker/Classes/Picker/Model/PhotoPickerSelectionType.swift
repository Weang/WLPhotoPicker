//
//  PhotoPickerSelectionType.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

// 可选择资源类型
public struct PhotoPickerSelectionType: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
}

public extension PhotoPickerSelectionType {
    
    // 照片，GIF、实况都处理为静态图片
    static let photo = PhotoPickerSelectionType(rawValue: 1 << 0)
    
    // 视频
    static let video = PhotoPickerSelectionType(rawValue: 1 << 1)
    
    // 动图
    static let GIF = PhotoPickerSelectionType(rawValue: 1 << 2)
    
    // 实况
    static let livePhoto = PhotoPickerSelectionType(rawValue: 1 << 3)
    
    // 所有类型
    static let all: PhotoPickerSelectionType = [.photo, .video, .GIF, .livePhoto]
    
}

public extension PhotoPickerSelectionType {
    
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

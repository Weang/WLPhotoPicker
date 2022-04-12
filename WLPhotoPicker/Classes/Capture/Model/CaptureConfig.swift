//
//  CaptureConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/11.
//

import UIKit
import MobileCoreServices

public class CaptureConfig {

    public init() { }
    // 是否允许拍摄照片
    public var captureAllowTakingPhoto: Bool = true
    
    // 是否允许拍摄视频
    public var captureAllowTakingVideo: Bool = true
    
    // 是否使用系统UIImagePickerController拍摄
    // 如果使用系统相机进行拍摄，下面的参数将会失效
    public var useSystemImagePickerController: Bool = false
    
    // 拍摄闪光灯开关
    public var captureFlashMode: CaptureFlashMode = .off
    
    // 视频拍摄最长时长
    public var captureMaximumVideoDuration: TimeInterval = 20
    
    // 视频拍摄格式
    public var captureFileType: CaptureVideoFileType = .mp4
    
    // 视频拍摄帧率
    public var captureVideoFrameRate: Double = 60
    
    // 视频拍摄质量
    public var captureSessionPreset: CaptureSessionPreset = .hd1920x1080
    
    // 视频拍摄防抖级别
    public var captureVideoStabilizationMode: CaptureVideoStabilizationMode = .auto
    
}

extension CaptureConfig {
    
    var showsCameraItem: Bool {
        captureAllowTakingPhoto || captureAllowTakingVideo
    }
    
    var imagePickerControllerMediaTypes: [String] {
        var mediaTypes: [String] = []
        if captureAllowTakingPhoto {
            mediaTypes.append(kUTTypeImage as String)
        }
        if captureAllowTakingVideo {
            mediaTypes.append(kUTTypeMovie as String)
        }
        return mediaTypes
    }
    
}

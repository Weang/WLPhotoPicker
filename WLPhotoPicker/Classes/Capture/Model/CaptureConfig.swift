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
    public var allowTakingPhoto: Bool = true
    
    // 是否允许拍摄视频
    public var allowTakingVideo: Bool = true
    
    // 视频拍摄最长时长
    public var captureMaximumVideoDuration: TimeInterval = 20
    
    // 拍摄闪光灯开关
    public var captureFlashMode: CaptureFlashMode = .off
    
    // 视频拍摄格式
    public var captureFileType: CaptureVideoFileType = .mp4
    
    // 视频拍摄帧率
    public var captureVideoFrameRate: Double = 60
    
    // 视频拍摄预设
    public var captureSessionPreset: CaptureSessionPreset = .hd4K3840x2160
    
    // 视频拍摄防抖模式
    public var captureVideoStabilizationMode: CaptureVideoStabilizationMode = .auto
    
}

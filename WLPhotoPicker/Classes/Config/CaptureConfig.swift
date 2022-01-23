//
//  CaptureConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/11.
//

import UIKit

public class CaptureConfig {

    public init() { }
    
    // 是否允许拍摄照片
    public var captureAllowTakingPhoto: Bool = true
    
    // 是否允许拍摄视频
    public var captureAllowTakingVideo: Bool = true
    
    // 拍摄比例
    public var captureAspectRatio: CaptureAspectRatio = .ratio16x9
    
    // 拍摄闪光灯开关
    public var captureFlashMode: CaptureFlashMode = .off
    
    // 拍摄视频最长时长
    public var captureMaximumVideoDuration: TimeInterval = 20
    
    // 视频拍摄格式
    public var captureFileType: CaptureFileType = .mp4
    
    // 视频帧率
    public var captureVideoFrameRate: Double = 60
    
    // 视频导出质量
    public var captureSessionPreset: CaptureSessionPreset = .hd1920x1080
    
    // 视频拍摄防抖级别
    public var captureVideoStabilizationMode: CaptureVideoStabilizationMode = .auto
    
}

//
//  AssetPickerResult.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit
import AVFoundation

public struct AssetPickerResult {
    
    // 资源模型
    public let asset: AssetModel
    
    // 如果选择的是图片，image参数是选择的图片或者编辑后的图片，选择原图时则是原图
    // 如果选择的是视频，image参数是视频的截图
    public var image: UIImage? = nil
    
    // 相册中未经过压缩的原视频
    public var playerItem: AVPlayerItem? = nil
    
    // 导出地址，需要设置PickerConfig的saveVideoToLocalWhenPick和saveImageToLocalWhenPick参数为true
    public var fileURL: URL? = nil
}

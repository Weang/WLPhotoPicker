//
//  PhotoPickerResult.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit
import AVFoundation
import Photos

public struct PhotoPickerResult {
    
    // 资源模型
    public let asset: AssetModel
    
    // 导出资源
    public let result: PhotoPickerResultType
    
    public var photo: UIImage? {
        switch result {
        case .photo(let result):
            return result.photo
        case .video(let result):
            return result.thumbnail
        case .livePhoto(let result):
            return result.photo
        }
    }
}

// 选中的资源结果类型
public enum PhotoPickerResultType {
    case photo(PhotoPickerPhotoResult)
    case video(PhotoPickerVideoResult)
    case livePhoto(PhotoPickerLivePhotoResult)
}

public struct PhotoPickerPhotoResult {
    
    // 选择的图片或者编辑后的图片
    public var photo: UIImage
    
    // 图片保存地址，exportImageURLWhenPick为true时不为空
    public var photoURL: URL? = nil
}

public struct PhotoPickerVideoResult {
    
    public var avasset: AVAsset
    
    // 相册中未经过压缩的原视频，用于预览
    public var playerItem: AVPlayerItem
    
    // 视频缩略图
    public var thumbnail: UIImage? = nil
    
    // 视频保存地址，exportVideoURLWhenPick为true时不为空
    public var videoURL: URL? = nil
}

public struct PhotoPickerLivePhotoResult {
    
    // 实况照片
    public var livePhoto: PHLivePhoto
    
    // 实况封面图
    public var photo: UIImage
    
    // 实况照片导出的视频地址
    // 视频导出不受exportImageURLWhenPick控制，只要选择实况照片就会导出视频
     public var videoURL: URL?
}

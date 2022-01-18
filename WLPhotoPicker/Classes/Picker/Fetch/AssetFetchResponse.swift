//
//  AssetExpertResponse.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/15.
//

import UIKit
import Photos
import AVKit

public struct PhotoFetchResponse {
    public let image: UIImage
    public let isDegraded: Bool
}

// 本地图片请求结果
public struct LocalPhotoFetchResponse {
    public let image: UIImage
    public let isDegraded: Bool
}

// iCloud data请求结果
public struct CloudPhotoFetchResponse {
    public let data: Data
    public let dataUTI: String
}

// 实况照片请求结果
public struct LivePhotoFetchResponse {
    public let livePhoto: PHLivePhoto
}

public struct GIFFetchResponse {
    public let image: UIImage
    public let imageData: Data
}

// 视频请求结果
public struct VideoFetchResponse {
    public let avasset: AVURLAsset
    public let playerItem: AVPlayerItem
}

// 视频导出结果
public struct VideoExportResponse {
    public let videoPath: String
}

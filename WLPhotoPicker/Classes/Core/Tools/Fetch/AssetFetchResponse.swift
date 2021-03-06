//
//  AssetExpertResponse.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/15.
//

import UIKit
import Photos
import AVKit

// 图片请求结果
struct PhotoFetchResponse {
    public let photo: UIImage
    public let isDegraded: Bool
}

// iCloud data请求结果
struct CloudPhotoFetchResponse {
    public let data: Data
    public let dataUTI: String
}

// 实况照片请求结果
struct LivePhotoFetchResponse {
    public let livePhoto: PHLivePhoto
}

// GIF请求结果
struct GIFFetchResponse {
    public let image: UIImage
    public let imageData: Data
}

// 视频请求结果
struct VideoFetchResponse {
    public let avasset: AVAsset
    public let playerItem: AVPlayerItem
}

//
//  AssetFetchOptions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/16.
//

import Photos

// https://blog.csdn.net/weixin_33919941/article/details/91379385
public class AssetFetchOptions {
    
    public var isNetworkAccessAllowed: Bool = true
    public var isSynchronous: Bool = false
    
    public var sizeOption: PhotoFetchSizeOptions = .specify(100)
    public var imageResizeMode: PHImageRequestOptionsResizeMode = .fast
    public let imageVersion: PHImageRequestOptionsVersion = .current
    public var imageDeliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic
    
    public var videoOutputPath: String?
    public let videoVersion: PHVideoRequestOptionsVersion = .current
    public var videoDeliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat
    
    public var progressHandler: ((Double) -> Void)? = nil
}

public enum PhotoFetchSizeOptions {
    case original
    case specify(CGFloat)
}

extension AssetFetchOptions {
    
    // requestImage方法中传入的targetSize会根据图片的短边来裁剪，导致预览图模糊
    func targetSizeWith(assetSize: CGSize) -> CGSize {
        let targetSize: CGSize
        switch sizeOption {
        case .original:
            targetSize = PHImageManagerMaximumSize
        case .specify(let size):
            let ratio = assetSize.width / assetSize.height
            if ratio < 1 {
                targetSize = CGSize(width: size / ratio, height: size / ratio)
            } else {
                targetSize = CGSize(width: size * ratio, height: size * ratio)
            }
        }
        return targetSize
    }
    
}

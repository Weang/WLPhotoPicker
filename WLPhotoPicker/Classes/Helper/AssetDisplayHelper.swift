//
//  AssetDisplayHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

class AssetDisplayHelper {
    
    // 返回适合于预览、编辑页面的imageView位置
    // 宽度是屏幕宽度，如果超过屏幕长会上下滚动
    static func imageViewRectFrom(imageSize: CGSize, mediaType: AssetMediaType) -> CGRect {
        let viewWidth = UIScreen.width
        let viewHeight = UIScreen.height
        
        let viewRatio = viewWidth / viewHeight
        let imageRatio = imageSize.width / imageSize.height
        
        var imageViewRect: CGRect = .zero
        
        if case .GIF = mediaType,
           imageSize.width < viewWidth && imageSize.height < viewHeight {
            imageViewRect.size.width = imageSize.width
            imageViewRect.size.height = imageSize.height
            imageViewRect.origin.x = (viewWidth - imageSize.width) * 0.5
            imageViewRect.origin.y = (viewHeight - imageSize.height) * 0.5
            return imageViewRect
        }
        
        imageViewRect.size.width = viewWidth
        if imageRatio > viewRatio {
            imageViewRect.size.height = viewWidth / imageRatio
            imageViewRect.origin.x = 0
            imageViewRect.origin.y = (viewHeight - imageViewRect.size.height) * 0.5
        } else {
            imageViewRect.size.height = viewWidth / imageRatio
            imageViewRect.origin.y = 0
            imageViewRect.origin.x = 0
        }
        return imageViewRect.rounded()
    }
    
    static func imageViewMaxZoomScaleFrom(imageSize: CGSize) -> CGFloat {
        if imageSize.ratio > 1 {
            return max(imageSize.width / UIScreen.width * 2, 2)
        } else {
            return 3
        }
    }
    
}

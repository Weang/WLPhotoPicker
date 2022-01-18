//
//  AssetSizeHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

class AssetSizeHelper {

    // 根据图片大小返回在屏幕大小中的自适应位置
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
        if imageRatio == viewRatio { // 屏幕比例，返回屏幕尺寸
            imageViewRect.size.height = viewHeight
            imageViewRect.origin.x = 0
            imageViewRect.origin.y = 0
        } else if imageRatio > viewRatio { // 相较于屏幕是宽图
            imageViewRect.size.height = viewWidth / imageRatio
            imageViewRect.origin.x = 0
            imageViewRect.origin.y = (viewHeight - imageViewRect.size.height) * 0.5
        } else {  // 老长老长的图
            imageViewRect.size.height = viewWidth / imageRatio
            imageViewRect.origin.y = 0
            imageViewRect.origin.x = 0
        }
        return imageViewRect
    }

    // 根据图片尺寸获得最大的放大比例
    static func imageViewMaxZoomScaleFrom(imageSize: CGSize) -> CGFloat {
        if imageSize.ratio > 1 { // 宽图
            return max(imageSize.width / UIScreen.width * 2, 2)
        } else {
            return 3
        }
    }
    
    static func imageViewCenterWhenZoom(_ scrollView: UIScrollView) -> CGPoint {
        let contentSize = scrollView.contentSize
        let contentInset = scrollView.contentInset
        let deltaWidth = max((scrollView.width - contentSize.width - contentInset.left - contentInset.right) * 0.5, 0)
        let deltaHeight = max((scrollView.height - contentSize.height - contentInset.top - contentInset.bottom) * 0.5, 0)
        return CGPoint(x: contentSize.width * 0.5 + deltaWidth,
                       y: contentSize.height * 0.5 + deltaHeight)
    }
    
    static func cropViewRectFrom(imageSize: CGSize, to viewsize: CGSize) -> CGRect {
        let viewWidth = viewsize.width
        let viewHeight = viewsize.height
        
        let viewRatio = viewWidth / viewHeight
        let imageRatio = imageSize.width / imageSize.height
        
        var imageViewRect: CGRect = .zero
        
        if imageRatio > viewRatio {
            imageViewRect.size.width = viewWidth
            imageViewRect.size.height = viewWidth / imageRatio
            imageViewRect.origin.x = 0
            imageViewRect.origin.y = (viewHeight - imageViewRect.size.height) * 0.5
        } else {
            imageViewRect.size.height = viewHeight
            imageViewRect.size.width = viewHeight * imageRatio
            imageViewRect.origin.y = 0
            imageViewRect.origin.x = (viewWidth - imageViewRect.size.width) * 0.5
        }
        return imageViewRect
    }
    
}

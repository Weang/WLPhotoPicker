//
//  UIScrollView+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/3/1.
//

import UIKit

extension UIScrollView {
    
    var zoomSubviewCenter: CGPoint {
        let deltaWidth = max((width - contentSize.width - contentInset.left - contentInset.right) * 0.5, 0)
        let deltaHeight = max((height - contentSize.height - contentInset.top - contentInset.bottom) * 0.5, 0)
        return CGPoint(x: contentSize.width * 0.5 + deltaWidth,
                       y: contentSize.height * 0.5 + deltaHeight)
    }
    
}

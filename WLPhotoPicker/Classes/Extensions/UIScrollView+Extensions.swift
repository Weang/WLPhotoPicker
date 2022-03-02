//
//  UIScrollView+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/3/1.
//

import UIKit

extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y == -(contentInset.top + safeAreaInsets.top)
    }
    
    var isAtBottom: Bool {
        let bottomOffset = contentSize.height - bounds.size.height + contentInset.bottom + safeAreaInsets.bottom
        return contentOffset.y == bottomOffset
    }
    
}

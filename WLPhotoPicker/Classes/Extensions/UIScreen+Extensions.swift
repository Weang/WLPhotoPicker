//
//  UIScreen+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit

extension UIScreen {
    
    static var size: CGSize {
        UIScreen.main.bounds.size
    }
    
    static var width: CGFloat {
        size.width
    }
    
    static var height: CGFloat {
        size.height
    }
    
}

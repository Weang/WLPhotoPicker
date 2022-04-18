//
//  CGRect+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/18.
//

import UIKit

extension CGRect {
    
    func rounded() -> CGRect {
        CGRect(x: origin.x.rounded(),
               y: origin.y.rounded(),
               width: size.width.rounded(),
               height: size.height.rounded())
    }
    
}

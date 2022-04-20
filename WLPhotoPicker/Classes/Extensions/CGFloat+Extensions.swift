//
//  CGFloat+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/19.
//

import UIKit

extension CGFloat {
    
    func between(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min {
            return min
        }
        if self > max {
            return max
        }
        return self
    }
    
}

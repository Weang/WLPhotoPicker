//
//  CGSize+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/31.
//

import UIKit

extension CGSize {

    var ratio: CGFloat {
        width / height
    }

    var turn: CGSize {
        CGSize(width: height, height: width)
    }
    
}

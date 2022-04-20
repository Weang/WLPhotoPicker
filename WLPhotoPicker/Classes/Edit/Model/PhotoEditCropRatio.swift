//
//  PhotoEditCropRatio.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

public struct PhotoEditCropRatio {

    // width / height
    let ratio: CGFloat

    init(ratio: CGFloat) {
        self.ratio = ratio
    }
    
    static public let freedom = PhotoEditCropRatio(ratio: 0)
    static public let ratio_1_1 = PhotoEditCropRatio(ratio: 1)
    static public let ratio_16_9 = PhotoEditCropRatio(ratio: CGFloat(16) / CGFloat(9))
    static public let ratio_9_16 = PhotoEditCropRatio(ratio: CGFloat(9) / CGFloat(16))
    static public let ratio_4_3 = PhotoEditCropRatio(ratio: CGFloat(4) / CGFloat(3))
    static public let ratio_3_4 = PhotoEditCropRatio(ratio: CGFloat(3) / CGFloat(4))
    
}

extension PhotoEditCropRatio: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.ratio == rhs.ratio
    }
    
}

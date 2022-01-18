//
//  PhotoEditCropRatio.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

public class PhotoEditCropRatio {

    let name: String
    let ratio: CGFloat

    init(name: String, ratio: CGFloat) {
        self.name = name
        self.ratio = ratio
    }
    
}

public extension PhotoEditCropRatio {
    
    static let freedom = PhotoEditCropRatio(name: "自由", ratio: 0)
    static let ratio_1_1 = PhotoEditCropRatio(name: "1:1", ratio: 1)
    static let ratio_16_9 = PhotoEditCropRatio(name: "16:9", ratio: CGFloat(16) / CGFloat(9))
    static let ratio_9_16 = PhotoEditCropRatio(name: "9:16", ratio: CGFloat(9) / CGFloat(16))
    static let ratio_4_3 = PhotoEditCropRatio(name: "4:3", ratio: CGFloat(4) / CGFloat(3))
    static let ratio_3_4 = PhotoEditCropRatio(name: "3:4", ratio: CGFloat(3) / CGFloat(4))
    
}

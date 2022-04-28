//
//  PhotoEditFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/9.
//

import UIKit

public typealias FilterProviderClosure = (UIImage?) -> UIImage?

public protocol PhotoEditFilterProvider {
    var name: String { get }
    var filter: FilterProviderClosure? { get }
}

class PhotoEditFilterHelper {
    
    static func getColor(red: Int, green: Int, blue: Int, alpha: Int = 255) -> CIColor {
        return CIColor(red: CGFloat(Double(red) / 255.0),
                       green: CGFloat(Double(green) / 255.0),
                       blue: CGFloat(Double(blue) / 255.0),
                       alpha: CGFloat(Double(alpha) / 255.0))
    }
    
    static func getColorImage(red: Int, green: Int, blue: Int, alpha: Int = 255, rect: CGRect) -> CIImage {
        let color = getColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }
    
}

public class PhotoEditDefaultFilter {
    
    static let original = PhotoEditOriginalFilter()
    
    static public let fade = PhotoEditCIFilter(name: "Fade", filterName: "CIPhotoEffectFade")
    static public let chrome = PhotoEditCIFilter(name: "Chrome", filterName: "CIPhotoEffectChrome")
    static public let transfer = PhotoEditCIFilter(name: "Transfer", filterName: "CIPhotoEffectTransfer")
    static public let mono = PhotoEditCIFilter(name: "Mono", filterName: "CIPhotoEffectMono")
    static public let noir = PhotoEditCIFilter(name: "Noir", filterName: "CIPhotoEffectNoir")
    static public let tonal = PhotoEditCIFilter(name: "Tonal", filterName: "CIPhotoEffectTonal")
    static public let clarendon = PhotoEditClarendonFilter()
    static public let nashville = PhotoEditNashvilleFilter()
    static public let apply1977 = PhotoEdit1977Filter()
    static public let toaster = PhotoEditToasterFilter()
    
    static public var all: [PhotoEditFilterProvider] {
        [fade, chrome, transfer, mono, noir, tonal, clarendon, nashville, apply1977, toaster]
    }
    
}

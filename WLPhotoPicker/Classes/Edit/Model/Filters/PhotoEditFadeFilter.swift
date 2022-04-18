//
//  PhotoEditFadeFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/10.
//

import UIKit

public class PhotoEditFadeFilter: PhotoEditFilterProvider {
    
    public var name: String {
        "Fade"
    }
    
    public var filter: FilterProviderClosure? {
        return { image in
            guard let ciImage = image?.toCIImage() else {
                return image
            }
            let filter = CIFilter(name: "CIPhotoEffectFade")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            guard let outputImage = filter?.outputImage?.toUIImage() else {
                return image
            }
            return outputImage
        }
    }
    
}

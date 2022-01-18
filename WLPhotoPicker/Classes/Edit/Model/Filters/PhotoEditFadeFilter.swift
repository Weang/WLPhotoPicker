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
    
    public func filterImage(_ image: UIImage?) -> UIImage? {
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

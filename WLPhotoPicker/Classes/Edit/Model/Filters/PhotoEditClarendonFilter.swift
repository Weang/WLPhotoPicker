//
//  PhotoEditClarendonFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/10.
//

import UIKit

class PhotoEditClarendonFilter: PhotoEditFilterProvider {
    
    public var name: String {
        "Clarendon"
    }
    
    public func filterImage(_ image: UIImage?) -> UIImage? {
        guard let ciImage = image?.toCIImage() else {
            return image
        }
        let color = CIColor(red: CGFloat(127.0 / 255.0),
                            green: CGFloat(187.0 / 255.0),
                            blue: CGFloat(227.0 / 255.0),
                            alpha: CGFloat(0.2))
        let backgroundImage = CIImage(color: color).cropped(to: ciImage.extent)
        let outputCIImage = ciImage.applyingFilter("CIOverlayBlendMode", parameters: [
            "inputBackgroundImage": backgroundImage
        ])
        guard let outputImage = outputCIImage.toUIImage() else {
            return image
        }
        return outputImage
    }
    
}

//
//  PhotoEditNashvilleFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/18.
//

import UIKit

public class PhotoEditNashvilleFilter: PhotoEditFilterProvider {
    
    public var name: String {
        "Fade"
    }
    
    public var filter: FilterProviderClosure? {
        return { image in
            guard let ciImage = image?.toCIImage() else {
                return image
            }
            
            let backgroundImage = PhotoEditFilterHelper.getColorImage(red: 247, green: 176, blue: 153, alpha: Int(255 * 0.56),
                                                                      rect: ciImage.extent)
            let backgroundImage2 = PhotoEditFilterHelper.getColorImage(red: 0, green: 70, blue: 150, alpha: Int(255 * 0.4),
                                                                       rect: ciImage.extent)
            let outputCIImage = ciImage
                .applyingFilter("CIDarkenBlendMode", parameters: [
                    "inputBackgroundImage": backgroundImage
                ])
                .applyingFilter("CISepiaTone", parameters: [
                    "inputIntensity": 0.2
                ])
                .applyingFilter("CIColorControls", parameters: [
                    "inputSaturation": 1.2,
                    "inputBrightness": 0.05,
                    "inputContrast": 1.1
                ])
                .applyingFilter("CILightenBlendMode", parameters: [
                    "inputBackgroundImage": backgroundImage2
                ])
            
            guard let outputImage = outputCIImage.toUIImage() else {
                return image
            }
            return outputImage
        }
    }
    
}

//
//  PhotoEdit1977Filter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/18.
//

import UIKit

public class PhotoEdit1977Filter: PhotoEditFilterProvider {
    
    public var name: String {
        "1977"
    }
    
    public var filter: FilterProviderClosure? {
        return { image in
            guard let ciImage = image?.toCIImage() else {
                return image
            }
            
            let filterImage = PhotoEditFilterHelper.getColorImage(red: 243, green: 106, blue: 188, alpha: Int(255 * 0.1), rect: ciImage.extent)
            let backgroundImage = ciImage
                .applyingFilter("CIColorControls", parameters: [
                    "inputSaturation": 1.3,
                    "inputBrightness": 0.1,
                    "inputContrast": 1.05
                ])
                .applyingFilter("CIHueAdjust", parameters: [
                    "inputAngle": 0.3
                ])
            
            let outputCIImage = filterImage
                .applyingFilter("CIScreenBlendMode", parameters: [
                    "inputBackgroundImage": backgroundImage
                ])
                .applyingFilter("CIToneCurve", parameters: [
                    "inputPoint0": CIVector(x: 0, y: 0),
                    "inputPoint1": CIVector(x: 0.25, y: 0.20),
                    "inputPoint2": CIVector(x: 0.5, y: 0.5),
                    "inputPoint3": CIVector(x: 0.75, y: 0.80),
                    "inputPoint4": CIVector(x: 1, y: 1)
                ])
            
            guard let outputImage = outputCIImage.toUIImage() else {
                return image
            }
            return outputImage
        }
    }
    
}

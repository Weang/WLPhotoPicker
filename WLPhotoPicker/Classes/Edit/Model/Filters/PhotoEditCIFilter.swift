//
//  PhotoEditCIFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/27.
//

import UIKit

public class PhotoEditCIFilter: PhotoEditFilterProvider {
    
    public var name: String
    public let filterName: String
    
    public init(name: String, filterName: String) {
        self.name = name
        self.filterName = filterName
    }
    
    public var filter: FilterProviderClosure? {
        let filterName = self.filterName
        return { image in
            guard let ciImage = image?.toCIImage() else {
                return image
            }
            let filter = CIFilter(name: filterName)
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            guard let outputImage = filter?.outputImage?.toUIImage() else {
                return image
            }
            return outputImage
        }
    }
    
}

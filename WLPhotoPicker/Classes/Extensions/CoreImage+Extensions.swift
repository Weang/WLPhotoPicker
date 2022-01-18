//
//  CoreImage+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/17.
//

import CoreImage

extension CGImageSource {
    
    var size: CGSize {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(self, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat else {
                  return .zero
              }
        return CGSize(width: width, height: height)
    }
    
}

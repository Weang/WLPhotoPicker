//
//  ImageGenerator.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/12.
//

import UIKit

public class ImageGenerator {
    
    static public func createImage(_ data: Data) -> UIImage? {
        guard var image = CIImage(data: data) else {
            return nil
        }
        
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
           let orlginalOrientation = metadata[kCGImagePropertyOrientation as String] as? Int32 {
            image = image.oriented(forExifOrientation: orlginalOrientation)
        }
        
        guard let cgImage = CIContext().createCGImage(image, from: image.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
}

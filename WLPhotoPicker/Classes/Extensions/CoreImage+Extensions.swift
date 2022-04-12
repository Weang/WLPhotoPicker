//
//  CoreImage+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/17.
//

import CoreImage

extension CIImage {
    
    func toUIImage() -> UIImage? {
        guard let cgImage = CIContext().createCGImage(self, from: extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
}

extension UIImage {
    
    func toCIImage() -> CIImage? {
        if let ciImage = self.ciImage {
            return ciImage
        }
        if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
    
}

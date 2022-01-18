//
//  CIImage+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/11.
//

import UIKit

extension CIImage {
    
    func toUIImage() -> UIImage? {
        guard let cgImage = CIContext().createCGImage(self, from: extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
}

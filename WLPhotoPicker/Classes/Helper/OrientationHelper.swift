//
//  OrientationHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import Photos
import CoreImage

class OrientationHelper {
    
    static func cgImageOrientationFrom(_ orientation: AVCaptureVideoOrientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .portrait:
            return .up
        case .portraitUpsideDown:
            return .down
        case .landscapeLeft:
            return .right
        case .landscapeRight:
            return .left
        @unknown default:
            return .up
        }
    }
    
    public static func imageRotateWith(_ imageOrientation: UIInterfaceOrientation) -> Double {
        let rotate: Double
        switch imageOrientation {
        case .portraitUpsideDown:
            rotate = 180
        case .landscapeLeft:
            rotate = -90
        case .landscapeRight:
            rotate = 90
        default:
            rotate = 0
        }
        return rotate
    }
    
    public static func videoRotateWith(_ videoOrientation: UIInterfaceOrientation) -> Double {
        let rotate: Double
        switch videoOrientation {
        case .landscapeRight:
            rotate = .pi
        case .landscapeLeft:
            rotate = 0
        case .portraitUpsideDown:
            rotate = .pi * 1.5
        default:
            rotate = .pi * 0.5
        }
        return rotate
    }

}

extension OrientationHelper {
    
    static func rotateImage(photoData: Data, orientation: AVCaptureVideoOrientation) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(photoData as CFData, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let orlginalOrientation = metadata[kCGImagePropertyOrientation as String] as? Int32,
              let orlginalImage = CIImage(data: photoData)?.oriented(forExifOrientation: orlginalOrientation) else {
                  return nil
              }
        let toOrientation = Int32(cgImageOrientationFrom(orientation).rawValue)
        let fixedImage = orlginalImage.oriented(forExifOrientation: toOrientation)
        guard let cgImage = CIContext().createCGImage(fixedImage, from: fixedImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    static func rotateImage(_ image: UIImage, withAngle angle: Double) -> UIImage? {
        if angle.truncatingRemainder(dividingBy: 360) == 0 {
            return image
        }
        
        let imageRect = CGRect(origin: .zero, size: image.size)
        let rotate = CGFloat(angle / 180 * .pi)
        let rotatedTransform = CGAffineTransform.identity.rotated(by: rotate)
        var rotatedRect = imageRect.applying(rotatedTransform)
        rotatedRect.origin.x = 0
        rotatedRect.origin.y = 0
        UIGraphicsBeginImageContextWithOptions(rotatedRect.size, false, image.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)
        context?.rotate(by: rotate)
        context?.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
        image.draw(at: .zero)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

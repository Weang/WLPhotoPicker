//
//  EditManager.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/12.
//

import UIKit

public class EditManager {
    
    private static let queue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.EditManager.Draw")
    
//    static func drawEditPreviewImageFrom(asset: AssetModel, photoEditConfig: PhotoEditConfig, completion: @escaping (UIImage?) -> Void) {
//        guard let previewImage = asset.previewImage else {
//            completion(nil)
//            return
//        }
//        imageFrom(photo: previewImage, asset: asset, photoEditConfig: photoEditConfig, completion: completion)
//    }
    
    static func drawEditOriginalImageFrom(asset: AssetModel, photoEditConfig: PhotoEditConfig, completion: @escaping (UIImage?) -> Void) {
        guard let originalImage = asset.originalImage else {
            completion(nil)
            return
        }
        imageFrom(photo: originalImage, asset: asset, photoEditConfig: photoEditConfig, completion: completion)
    }
    
    static private func imageFrom(photo: UIImage, asset: AssetModel, photoEditConfig: PhotoEditConfig, completion: @escaping (UIImage?) -> Void) {
        queue.async {
            // 这里之所以用previewImage作为马赛克的底图，是因为在选择原图时，大图马赛克效果和小图不一致
            // 所以使用小图的马赛克图片作为底图，保证在选择原图时输出的效果和编辑时一致
            // 如果图片被编辑过，那么previewImage一定不为空
            let mosaicMaskImage = (asset.filter?.filterImage(asset.previewImage) ?? asset.previewImage)?
                .adjustImageFrom(asset.adjustValue)
                .mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
            
            let adjustedImage = (asset.filter?.filterImage(photo) ?? photo).adjustImageFrom(asset.adjustValue)
            let image = asset.editMosaicPath.drawMosaicImage(from: adjustedImage, mosaicImage: mosaicMaskImage)
            
            let outputImage = drawMasksAt(photo: image, with: asset)
            DispatchQueue.main.async {
                completion(outputImage)
            }
        }
    }
    
    static func drawMasksAt(photo: UIImage?, with asset: AssetModel) -> UIImage? {
        return drawMasksAt(photo: photo, editGraffitiPath: asset.editGraffitiPath, maskLayers: asset.maskLayers)
    }
    
    static func drawMasksAt(photo: UIImage?, editGraffitiPath: PhotoEditGraffitiPath, maskLayers: [PhotoEditMaskLayer]) -> UIImage? {
        guard let photo = photo else {
            return nil
        }
        let contextRect = AssetSizeHelper.imageViewRectFrom(imageSize: photo.size, mediaType: .photo)
        let scale = photo.size.width / contextRect.size.width
        let rect = CGRect(origin: .zero, size: photo.size)
        UIGraphicsBeginImageContextWithOptions(photo.size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        photo.draw(in: rect)
        
        editGraffitiPath.imageSize = photo.size
        editGraffitiPath.draw()?.draw(in: rect)
        
        for maskLayer in maskLayers {
            let rectTransform = CGAffineTransform(scaleX: maskLayer.scale, y: maskLayer.scale)
                .rotated(by: maskLayer.rotation)
            let originRect = CGRect(origin: .zero, size: maskLayer.imageSize)
            var transformedFrame = originRect.applying(rectTransform)
            transformedFrame.origin.x = maskLayer.center.x - transformedFrame.width * 0.5 + maskLayer.translation.x
            transformedFrame.origin.y = maskLayer.center.y - transformedFrame.height * 0.5 + maskLayer.translation.y
            let imageTransform = CGAffineTransform(scaleX: maskLayer.scale, y: maskLayer.scale)
                .rotated(by: -maskLayer.rotation)
            let transformedImage = maskLayer.maskImage.toCIImage()?.transformed(by: imageTransform).toUIImage()
            transformedImage?.draw(in: CGRect(x: transformedFrame.origin.x * scale,
                                              y: transformedFrame.origin.y * scale,
                                              width: transformedFrame.size.width * scale,
                                              height:transformedFrame.size.height * scale))
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

//
//  EditManager.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/12.
//

import UIKit

class EditManager {
    
    private static let queue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.EditManager.Draw")
    
    let photo: UIImage
    let assetModel: AssetModel?
    
    var mosaicWidth: CGFloat = 30
    
    var editGraffitiPath = PhotoEditGraffitiPath()
    var editMosaicPath = PhotoEditMosaicPath()
    var cropRect: PhotoEditCropRect = .identity
    var cropOrientation: UIImage.Orientation = .up
    var maskLayers: [PhotoEditMaskLayer] = []
    var photoFilter: PhotoEditFilterProvider? = nil
    var selectedFilterIndex: Int = 0
    var adjustValue: [PhotoEditAdjustMode: Double] = [:]
    
    init(photo: UIImage, assetModel: AssetModel?) {
        self.photo = photo
        self.assetModel = assetModel
        
        guard let assetModel = assetModel, assetModel.hasEdit else {
            return
        }
        editGraffitiPath = assetModel.editGraffitiPath
        editMosaicPath = assetModel.editMosaicPath
        cropRect = assetModel.cropRect
        cropOrientation = assetModel.cropOrientation
        maskLayers = assetModel.maskLayers
        photoFilter = assetModel.photoFilter
        adjustValue = assetModel.adjustValue
    }
    
    func drawPhoto() -> UIImage? {
        let mosaicImage = (assetModel?.previewPhoto ?? photo).mosaicImage(level: mosaicWidth)
        let mosaicDrawedImage = editMosaicPath.drawMosaicImage(ornginalImage: photo, mosaicImage: mosaicImage)
        let filterImage = photoFilter?.filter?(mosaicDrawedImage) ?? mosaicDrawedImage
        let adjustedImage = filterImage?.adjustImageFrom(adjustValue)
        return adjustedImage
    }
    
    func drawOverlay(at photo: UIImage?, withCrop: Bool) -> UIImage? {
        guard let photo = photo else { return nil }
        
        let contextRect = AssetDisplayHelper.imageViewRectFrom(imageSize: photo.size, mediaType: .photo)
        let scale = photo.size.width / contextRect.size.width
        let rect = CGRect(origin: .zero, size: photo.size)
        UIGraphicsBeginImageContextWithOptions(photo.size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        photo.draw(in: rect)
        
        var editGraffitiPath = editGraffitiPath
        editGraffitiPath.contextSize = photo.size
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
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        if withCrop {
            return image?.rotate(orientation: cropOrientation)
                .cropToRect(cropRect)
        } else {
            return image
        }
    }
    
}

//
//  AssetModel.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

public class AssetModel {
    
    var isSelected: Bool = false
    var selectedIndex: Int = 0
    var isEnabled: Bool = true
    
    var editGraffitiPath = PhotoEditGraffitiPath()
    var editMosaicPath = PhotoEditMosaicPath()
    var cropRect: PhotoEditCropRect = .identity
    var cropRotation: UIImage.Orientation = .up
    var maskLayers: [PhotoEditMaskLayer] = []
    var filter: PhotoEditFilterProvider?
    var filterIndex: Int = 0
    var adjustValue: [PhotoEditAdjustMode: Double] = [:]
    
    var hasEdit: Bool {
        return editMosaicPath.pathLines.count > 0 ||
        editGraffitiPath.pathLines.count > 0 ||
        cropRect != .identity ||
        cropRotation != .up ||
        maskLayers.count > 0 ||
        filter != nil ||
        adjustValue.filter{ $0.value != 0 }.count > 0
    }
    
    public var previewImage: UIImage?
    public var editedImage: UIImage?
    public var originalImage: UIImage?
    public var displayingImage: UIImage? {
        if let editedImage = editedImage {
            return editedImage
        }
        return previewImage
    }
    
    public var mediaType: AssetMediaType {
        switch asset.mediaType {
        case .image where asset.isLivePhoto && pickerConfig.selectableType.contains(.livePhoto):
            return .livePhoto
        case .image where asset.isGIF && pickerConfig.selectableType.contains(.GIF):
            return .GIF
        case .video:
            return .video
        default:
            return .photo
        }
    }
    
    public var fileSuffix: String {
        switch mediaType{
        case .photo, .livePhoto:
            return ".jpg"
        case .video:
            return ".mp4"
        case .GIF:
            return ".gif"
        }
    }
    
    public var localIdentifier: String {
        asset.localIdentifier
    }
    
    public var duration: Double {
        asset.duration
    }
    
    public var videoDuration: String? {
        switch mediaType {
        case .video:
            let mins = Int(duration) / 60
            let sec = Int(duration) % 60
            return String(format: "%02d:%02d", mins, sec)
        default:
            return nil
        }
    }
    
    public var asset: PHAsset
    private let pickerConfig: PickerConfig
    
    init(asset: PHAsset, pickerConfig: PickerConfig) {
        self.asset = asset
        self.pickerConfig = pickerConfig
    }
    
}

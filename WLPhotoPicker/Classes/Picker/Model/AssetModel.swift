//
//  AssetModel.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

public class AssetModel {
    
    public var asset: PHAsset
    private let pickerConfig: PickerConfig
    
    public var isSelected: Bool = false
    public var selectedIndex: Int = 0
    public var isEnabled: Bool = true
    
    public var previewImage: UIImage?
    public var editedImage: UIImage?
    public var originalImage: UIImage?
    public var displayingImage: UIImage? {
        if let editedImage = editedImage {
            return editedImage
        }
        return previewImage
    }
    
    public var editMosaicPath = PhotoEditMosaicPath()
    public var editMosaicColorIndex: Int = 0
    public var editGraffitiPath = PhotoEditGraffitiPath()
    public var maskLayers: [PhotoEditMaskLayer] = []
    public var filter: PhotoEditFilterProvider?
    public var filterIndex: Int = 0
    public var adjustValue: [PhotoEditAdjustMode: Double] = [:]
    public var hasEdit: Bool {
        return editMosaicPath.pathLines.count > 0 ||
        editGraffitiPath.pathLines.count > 0 ||
        maskLayers.count > 0 ||
        filter != nil ||
        adjustValue.filter{ $0.value != 0 }.count > 0
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
    
    init(asset: PHAsset, pickerConfig: PickerConfig) {
        self.asset = asset
        self.pickerConfig = pickerConfig
    }
    
}

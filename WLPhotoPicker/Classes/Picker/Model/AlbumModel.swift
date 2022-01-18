//
//  AlbumModel.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

public class AlbumModel {
    
    public var assets: [AssetModel] = []
    public var coverAsset: AssetModel? {
        switch pickerConfig.sortType {
        case .asc:
            return assets.last
        case .desc:
            return assets.first
        }
    }
    
    public var localIdentifier: String {
        fetchCollection.localIdentifier
    }
    
    public var localizedTitle: String? {
        fetchCollection.localizedTitle
    }
    
    public var count: Int {
        assets.count
    }
    
    public var isCameraRollAlbum: Bool {
        fetchCollection.isCameraRollAlbum
    }
    
    public var selectPhoto: Bool {
        pickerConfig.selectableType.contains(.photo)
    }
    
    public var selectVideo: Bool {
        pickerConfig.selectableType.contains(.video)
    }
    
    public var selectPhotoGIF: Bool {
        pickerConfig.selectableType.contains(.GIF)
    }
    
    public var selectPhotoLive: Bool {
        pickerConfig.selectableType.contains(.livePhoto)
    }
    
    private let pickerConfig: PickerConfig
    var fetchResult: PHFetchResult<PHAsset>
    let fetchCollection: PHAssetCollection
    
    init(result: PHFetchResult<PHAsset>, collection: PHAssetCollection, pickerConfig: PickerConfig) {
        self.fetchResult = result
        self.fetchCollection = collection
        self.pickerConfig = pickerConfig
        
        let objects = result.objects
        for obj in objects {
            if let assetModel = shouldAppendAsset(asset: obj) {
                assets.append(assetModel)
            }
        }
    }
    
    func shouldAppendAsset(asset: PHAsset) -> AssetModel? {
        let asset = AssetModel(asset: asset, pickerConfig: pickerConfig)
        switch asset.mediaType {
        case .photo where self.selectPhoto:
            return asset
        case .video where self.selectVideo:
            let maximumVideoDuration = pickerConfig.pickerMaximumVideoDuration
            if maximumVideoDuration != 0 && asset.duration > maximumVideoDuration {
                return nil
            }
            return asset
        case .GIF where self.selectPhotoGIF:
            return asset
        case .livePhoto where self.selectPhotoLive:
            return asset
        default:
            return nil
        }
    }
    
}

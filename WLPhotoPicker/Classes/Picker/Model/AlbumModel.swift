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
    
    public var count: Int {
        assets.count
    }
    
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
    
    public var localizedTitle: String {
        fetchCollection.localizedTitle ?? ""
    }
    
    public var isCameraRollAlbum: Bool {
        fetchCollection.isCameraRollAlbum
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
        case .photo where pickerConfig.selectableType.contains(.photo):
            return asset
        case .video where pickerConfig.selectableType.contains(.video):
            let maximumVideoDuration = pickerConfig.pickerMaximumVideoDuration
            if maximumVideoDuration != 0 && asset.duration > maximumVideoDuration {
                return nil
            }
            return asset
        case .GIF where pickerConfig.selectableType.contains(.GIF):
            return asset
        case .livePhoto where pickerConfig.selectableType.contains(.livePhoto):
            return asset
        default:
            return nil
        }
    }
    
}

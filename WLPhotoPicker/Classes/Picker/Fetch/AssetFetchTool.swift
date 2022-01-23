//
//  AssetFetchTool.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

protocol AssetFetchToolDelegate: NSObjectProtocol {
    
    // 加载所有照片的相册结束
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetchCameraAlbum albumModel: AlbumModel)
    
    // 加载所有相册结束
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetch allAlbums: [AlbumModel])
    
    // 选中状态变化
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateSelectedStatus assetModel: AssetModel)
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetchSelectedAsset assetModel: AssetModel)
    
    // 相册更新
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateAlbum albumModel: AlbumModel,
                        insertedItems: IndexSet,
                        removedItems: IndexSet,
                        changedItems: IndexSet)
    
}

extension AssetFetchToolDelegate {
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetchCameraAlbum albumModel: AlbumModel) { }
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetch allAlbums: [AlbumModel]) { }
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateSelectedStatus assetModel: AssetModel) { }
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetchSelectedAsset assetModel: AssetModel) { }
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateAlbum albumModel: AlbumModel, insertedItems: IndexSet, removedItems: IndexSet, changedItems: IndexSet) { }
}

class AssetFetchTool: NSObject {
    
    static let queue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.AssetFetchTool.Fetch")
    var assetFetchQueue = OperationQueue()
    
    var albumModel: AlbumModel?
    var albumsList: [AlbumModel] = []
    var selectedAssets: [AssetModel] = []
    
    var isOriginal = false
    
    // 记录相机保存的localIdentifier，在刷新相册时选中
    var captureLocalIdentifier: String?
    
    let config: WLPhotoConfig
    
    var pickerConfig: PickerConfig {
        config.pickerConfig
    }
    
    var photoEditConfig: PhotoEditConfig {
        config.photoEditConfig
    }
    
    init(config: WLPhotoConfig) {
        self.config = config
        super.init()
        assetFetchQueue.maxConcurrentOperationCount = 3
    }
    
    func register() {
        PHPhotoLibrary.shared().register(self)
    }
    
    var delegates: [WeakAssetFetchToolDelegate] = []
    
    func addDelegate(_ observer: AssetFetchToolDelegate) {
        delegates.append(WeakAssetFetchToolDelegate(value: observer))
    }
    
    func removeDeleagte(_ observer: AssetFetchToolDelegate) {
        delegates.removeAll(where: {
            $0.value?.isEqual(observer) ?? false
        })
        delegates.removeAll(where: {
            $0.value == nil
        })
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

extension AssetFetchTool {
    
    static func handleInfo(_ info: [AnyHashable: Any]?) -> AssetFetchError? {
        guard let info = info else {
            return AssetFetchError.fetchFailed
        }
        if let isCancelled = info[PHImageCancelledKey] as? Bool, isCancelled {
            return AssetFetchError.canceled
        }
        if let isInCloud = info[PHImageResultIsInCloudKey] as? Bool, isInCloud {
            return AssetFetchError.cannotFindInLocal
        }
        if let error = info[PHImageErrorKey] as? Error {
            return AssetFetchError.underlying(error)
        }
        return nil
    }
    
}

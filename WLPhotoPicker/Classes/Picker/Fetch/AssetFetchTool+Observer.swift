//
//  AssetFetchTool+Observer.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/23.
//

import Photos

extension AssetFetchTool: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let album = albumModel,
              let changeDetails = changeInstance.changeDetails(for: album.fetchResult) else {
                  return
              }
        AssetFetchTool.queue.async { [weak self] in
            if !changeDetails.hasIncrementalChanges {
                self?.updateAlbum(album, withChangeDetails: changeDetails, changeInstance: changeInstance)
            }
            if changeDetails.hasIncrementalChanges,
               changeDetails.insertedObjects.count > 0 ||
                changeDetails.removedObjects.count > 0 ||
                changeDetails.changedObjects.count > 0 {
                self?.updateAlbum(album, withChangeDetails: changeDetails, changeInstance: changeInstance)
            }
        }
    }
    
    func updateAlbum(_ album: AlbumModel, withChangeDetails detail: PHFetchResultChangeDetails<PHAsset>, changeInstance: PHChange) {
        // 重新加载相册
        let afterAlbumModel = AlbumModel(result: detail.fetchResultAfterChanges,
                                         collection: album.fetchCollection,
                                         pickerConfig: pickerConfig)
        
        // 新旧资源map
        var beforeAssetMap: [String: AssetModel] = [:]
        var afterAssetMap: [String: AssetModel] = [:]
        album.assets.forEach {
            beforeAssetMap[$0.localIdentifier] = $0
        }
        afterAlbumModel.assets.forEach {
            afterAssetMap[$0.localIdentifier] = $0
        }
        var removedItems = IndexSet()
        var insertedItems = IndexSet()
        var changedItems = IndexSet()
        
        // 旧加载的资源中有新资源不存在的，则为删除
        for (index, asset) in album.assets.enumerated() where afterAssetMap[asset.localIdentifier] == nil {
            deselectedAsset(asset: asset, delegateEvent: false)
            album.assets.removeAll(where: {
                $0.localIdentifier == asset.localIdentifier
            })
            removedItems.insert(index)
        }
        
        // 新加载的资源中有旧资源不存在的，则为新增
        for (index, asset) in afterAlbumModel.assets.enumerated() where beforeAssetMap[asset.localIdentifier] == nil {
            album.assets.insert(asset, at: index)
            insertedItems.insert(index)
            // 相机拍摄的照片视频
            if let captureLocalIdentifier = self.captureLocalIdentifier,
               asset.localIdentifier == captureLocalIdentifier {
                selectedAsset(asset: asset, delegateEvent: false)
                self.captureLocalIdentifier = nil
            } else if !detail.hasIncrementalChanges &&
                        PermissionProvider.statusFor(.photoLibrary) == .limited &&
                        pickerConfig.autoSelectAssetFromLimitedLibraryPicker {
                if isUptoLimit {
                    asset.isEnabled = false
                }
                selectedAsset(asset: asset, delegateEvent: false)
            }
        }
        
        for changedIndex in detail.changedIndexes ?? IndexSet() {
            let changedAsset = detail.fetchResultAfterChanges[changedIndex]
            if let assetIndex = album.assets.firstIndex(where: { $0.localIdentifier == changedAsset.localIdentifier }) {
                let contentChanged = changeInstance.changeDetails(for: album.assets[assetIndex].asset)?.assetContentChanged
                if contentChanged ?? false {
                    album.assets[assetIndex].asset = changedAsset
                    changedItems.insert(assetIndex)
                }
            }
        }
        
        album.fetchResult = detail.fetchResultAfterChanges
        
        if let index = albumsList.firstIndex(where: { $0.localIdentifier == album.localIdentifier }) {
            albumsList[index] = album
        }
        
        if removedItems.count == 0 && insertedItems.count == 0 && changedItems.count == 0 {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegates.forEach { delegate in
                delegate.value?.assetFetchTool(self,
                                               updateAlbum: album,
                                               insertedItems: insertedItems,
                                               removedItems: removedItems,
                                               changedItems: changedItems)
            }
        }
    }
    
}

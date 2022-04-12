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
        AssetFetchTool.albumQueue.async { [weak self] in
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
        let afterAlbumModel = AlbumModel(result: detail.fetchResultAfterChanges, collection: album.fetchCollection, pickerConfig: pickerConfig)
        
        // 新旧资源map
        var beforeAssetMap: [String: AssetModel] = [:]
        var afterAssetMap: [String: AssetModel] = [:]
        album.assets.forEach {
            beforeAssetMap[$0.localIdentifier] = $0
        }
        afterAlbumModel.assets.forEach {
            afterAssetMap[$0.localIdentifier] = $0
        }
        
        // 被修改的indexs
        var removedItems = IndexSet()
        var removedAssetItems: [AssetModel] = []
        var insertedItems = IndexSet()
        var changedItems = IndexSet()
        
        // 旧的资源中有新资源不存在的，则为删除
        for (index, asset) in album.assets.enumerated() where afterAssetMap[asset.localIdentifier] == nil {
            deselectedAsset(asset: asset, delegateEvent: false) // 取消选中
            album.assets.removeAll(where: {
                $0.localIdentifier == asset.localIdentifier
            })
            removedAssetItems.append(asset)
            removedItems.insert(index)
        }
        
        // 新的资源中有旧资源不存在的，则为新增
        for (index, asset) in afterAlbumModel.assets.enumerated() where beforeAssetMap[asset.localIdentifier] == nil {
            album.assets.insert(asset, at: index)
            insertedItems.insert(index)
            // 相机拍摄的照片视频
            if let captureLocalIdentifier = self.captureLocalIdentifier,
               asset.localIdentifier == captureLocalIdentifier {
                self.captureLocalIdentifier = nil
                if !isUptoLimit {
                    selectedAsset(asset: asset, delegateEvent: false)
                } else {
                    asset.isEnabled = false
                }
            }
            // limited权限选中照片默认选中
            if !detail.hasIncrementalChanges &&
                PermissionProvider.statusFor(.photoLibrary) == .limited {
                if isUptoLimit {
                    asset.isEnabled = false
                } else if pickerConfig.autoSelectAssetFromLimitedLibraryPicker {
                    selectedAsset(asset: asset, delegateEvent: false)
                }
            }
        }
        
        // 变更的资源
        // 从icloud下载图片后，也会触发这个方法，所以判断assetContentChanged，区别是照片修改还是下载
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
        
        // 更新当前相册
        if let index = albumsList.firstIndex(where: { $0.localIdentifier == album.localIdentifier }) {
            albumsList[index] = album
        }
        
        if removedItems.count == 0 && insertedItems.count == 0 && changedItems.count == 0 {
            return
        }
        
        // 删除所有相册中包含的已删除的项
        if removedItems.count > 0 {
            for album in albumsList {
                album.assets.removeAll(where: { asset -> Bool in
                    removedAssetItems.contains(where: {
                        $0.localIdentifier == asset.localIdentifier
                    })
                })
            }
            albumsList.removeAll(where: {
                $0.count == 0
            })
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegates.forEach { delegate in
                delegate.value?.assetFetchTool(self, updateAlbum: album, insertedItems: insertedItems, removedItems: removedItems, changedItems: changedItems)
            }
        }
    }
    
}

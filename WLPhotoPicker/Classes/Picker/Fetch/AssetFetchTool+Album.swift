//
//  AssetFetchTool+Album.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/15.
//

import UIKit
import Photos

extension AssetFetchTool {
    
    private var assetFetchOptions: PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        if !pickerConfig.selectableType.hasVideo {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !pickerConfig.selectableType.hasPhoto {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if pickerConfig.sortType == .desc {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [sortDescriptor]
        }
        return fetchOptions
    }
    
    func fetchCameraRollAlbum() {
        AssetFetchTool.queue.async { [weak self] in
            guard let self = self else { return }
            let assetCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            let collections = assetCollections.objects.filter {
                $0.estimatedAssetCount > 0 && $0.isCameraRollAlbum
            }
            guard let cameraRollAlbumCollection = collections.first else {
                return
            }
            let assetFetchResult = PHAsset.fetchAssets(in: cameraRollAlbumCollection, options: self.assetFetchOptions)
            let albumModel = AlbumModel(result: assetFetchResult, collection: cameraRollAlbumCollection, pickerConfig: self.pickerConfig)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.albumModel = albumModel
                self.delegates.forEach {
                    $0.value?.assetFetchTool(self, finishFetchCameraAlbum: albumModel)
                }
            }
        }
    }
    
    func fetchAllAlbums() {
        AssetFetchTool.queue.async { [weak self] in
            guard let self = self else { return }
            
            var albumArray: [AlbumModel] = []
            var collections: [PHAssetCollection] = []
            
            let subtypes: [PHAssetCollectionSubtype] = [
                .albumMyPhotoStream,
                .albumSyncedAlbum,
                .albumCloudShared,
                .albumRegular
            ]
            let smartAlbumCollections = subtypes.map {
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil)
            }.map {
                $0.objects
            }.flatMap{
                $0
            }
            
            let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil).objects.compactMap {
                $0 as? PHAssetCollection
            }
            
            collections.append(contentsOf: smartAlbumCollections)
            collections.append(contentsOf: topLevelUserCollections)
            
            for collection in collections {
                let assetFetchResult = PHAsset.fetchAssets(in: collection, options: self.assetFetchOptions)
                if albumArray.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                    continue
                }
                if collection.estimatedAssetCount <= 0 && !collection.isCameraRollAlbum {
                    continue
                }
                if collection.isHiddenAlbum || collection.isRecentlyDeletedAlbum {
                    continue
                }
                if assetFetchResult.count == 0 && !collection.isCameraRollAlbum {
                    continue
                }
                let albumModel = AlbumModel(result: assetFetchResult, collection: collection, pickerConfig: self.pickerConfig)
                if collection.isCameraRollAlbum {
                    albumArray.insert(albumModel, at: 0)
                } else if albumModel.count > 0 {
                    albumArray.append(albumModel)
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.albumsList = albumArray
                self.delegates.forEach {
                    $0.value?.assetFetchTool(self, finishFetch: albumArray)
                }
            }
        }
    }
    
}

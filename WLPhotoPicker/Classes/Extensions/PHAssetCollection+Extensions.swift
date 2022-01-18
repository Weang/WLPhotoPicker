//
//  PHAssetCollection+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

extension PHAssetCollection {

    var isCameraRollAlbum: Bool {
        assetCollectionSubtype == .smartAlbumUserLibrary
    }
    
    var isHiddenAlbum: Bool {
        assetCollectionSubtype == .smartAlbumAllHidden
    }
    
    var isRecentlyDeletedAlbum: Bool {
        assetCollectionSubtype.rawValue == 1000000201
    }
    
}

//
//  PHFetchResult+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit
import Photos

extension PHFetchResult where ObjectType == PHAssetCollection {
    
    var objects: [PHAssetCollection] {
        var objects: [PHAssetCollection] = []
        for i in 0..<count {
            objects.append(object(at: i))
        }
        return objects
    }
    
}

extension PHFetchResult where ObjectType == PHCollection {
    
    var objects: [PHCollection] {
        var objects: [PHCollection] = []
        for i in 0..<count {
            objects.append(object(at: i))
        }
        return objects
    }
    
}

extension PHFetchResult where ObjectType == PHAsset {
    
    var objects: [PHAsset] {
        var objects: [PHAsset] = []
        for i in 0..<count {
            objects.append(object(at: i))
        }
        return objects
    }
    
}

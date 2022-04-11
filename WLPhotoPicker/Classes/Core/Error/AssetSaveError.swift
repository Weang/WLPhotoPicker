//
//  AssetSaveError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/3.
//

import UIKit

public enum AssetSaveError: Error {
    case invalidVideoURL
    case savePhotoFailed
    case saveLivePhotoFailed
    case saveVideoFailed
}

//
//  VideoExportError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import UIKit

public enum VideoCompressError: Error {
    case failedToLoadAssetTrack
    case failedToCreateCompositionTrack
    case failedToReadAsset
    case failedToCreateAssetWriter
    case underlying(Error)
}

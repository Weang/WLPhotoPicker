//
//  VideoExportError.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import UIKit

public enum VideoExportError: Error {
    case createAssetTrack
    case createExportSession
    case exportSessionError
    case underlying(Error)
}

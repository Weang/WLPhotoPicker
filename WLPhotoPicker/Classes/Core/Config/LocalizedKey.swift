//
//  LocalizedKey.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/14.
//

import UIKit

public enum LanguageType: String {
    case automatic
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"
}

extension LanguageType {
    
    var bundleName: String {
        switch self {
        case .automatic:
            guard let language = Locale.preferredLanguages.first else {
                return "en"
            }
            return LanguageRegionCode.languageCodeWith(language)
        default:
            return rawValue
        }
    }
    
}

public enum LocalizedKey: String {
    
    // Public
    case Cancel
    case Confirm
    case Done
    case Processing
    case Alert
    case OriginalImage
    case Edit
    case ICloudLoading
    case LivePhoto
    
    // Picker
    case CountLimitedTip
    case AddMore
    case UnableToAccessAlbum
    case AlbumPermissionDeniedAlert
    case AlbumPermissionLimitedAlert
    case GoSetting
    
    // Eidt
    case DragHereToDelete
    case RemoveToDelete
    
    // Capture
    case TapToTakePhoto
    case HoldOnToTakeVideo
    
    // Error
    case InvalidInfo
    case Canceled
    case FailedToFetchPhoto
    case FailedToFetchGIF
    case FailedToFetchLivePhoto
    case FailedToFetchVideo
    case FailedToExportPhoto
    case FailedToExportVideo
    case FailedToInitializeCameraDevice
    case FailedToInitializeMicrophoneDevice
    case FailedToLoadAsset
    case FailedToWriteAsset
}

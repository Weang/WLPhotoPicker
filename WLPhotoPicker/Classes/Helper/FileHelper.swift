//
//  FileHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/23.
//

import UIKit

class FileHelper {
    
    static var temporaryPath: String {
        return NSTemporaryDirectory() + "WLPhoto/"
    }
    
    static var dateString: String {
        String(Date().timeIntervalSince1970)
    }
    
    static func createSubDirectory(_ name: String) -> String {
        let directoryPath = temporaryPath + name + "/"
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: directoryPath),
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        return directoryPath
    }
    
}

// MARK: Picker
extension FileHelper {
    
    static func createFileName(asset: AssetModel) -> String {
        return (asset.localIdentifier.replacingOccurrences(of: "/", with: "-") + dateString).md5
    }
    
    static func createFilePathFrom(asset: AssetModel) -> String {
        let directoryPath = createSubDirectory("Picker")
        let fileName = createFileName(asset: asset)
        return directoryPath + fileName + asset.fileSuffix
    }
    
    static func createVideoPathFrom(asset: AssetModel, videoFileType: PickerVideoExportFileType) -> String {
        let directoryPath = createSubDirectory("Picker")
        let fileName = createFileName(asset: asset)
        return directoryPath + fileName + videoFileType.suffix
    }
    
}

// MARK: LivePhoto
extension FileHelper {
    
    static func createLivePhotoPhotoPath() -> String {
        let directoryPath = createSubDirectory("LivePhoto")
        return directoryPath + dateString.md5 + ".jpg"
    }
    
    static func createLivePhotoVideoPath() -> String {
        let directoryPath = createSubDirectory("LivePhoto")
        return directoryPath + dateString.md5 + ".mov"
    }
    
}

// MARK: Capture
extension FileHelper {
    
    static func createCapturePhotoPath() -> String {
        let directoryPath = createSubDirectory("Capture")
        return directoryPath + dateString.md5 + ".jpg"
    }
    
    static func createCaptureVideoPath(fileType: CaptureVideoFileType) -> String {
        let directoryPath = createSubDirectory("Capture")
        return directoryPath + dateString.md5 + fileType.suffix
    }
    
}

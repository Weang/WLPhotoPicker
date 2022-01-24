//
//  FileHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/23.
//

import UIKit

public class FileHelper {
    
    public static var temporaryPath: String {
        let path = NSTemporaryDirectory() + "WLPhoto/"
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }
    
}

// MARK: Picker
public extension FileHelper {
    
    static func createFileNamePrefixFrom(asset: AssetModel) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let fileNamePrefix = asset.localIdentifier.replacingOccurrences(of: "/", with: "-") + dateFormatter.string(from: Date())
        return fileNamePrefix.md5
    }
    
    static func createFilePathFrom(asset: AssetModel) -> String {
        let fileNamePrefix = createFileNamePrefixFrom(asset: asset)
        let fileName = fileNamePrefix + asset.fileSuffix
        return temporaryPath + fileName
    }
    
    static func createVideoPathFrom(asset: AssetModel, videoFileType: AssetVideoExportFileType) -> String {
        let fileNamePrefix = createFileNamePrefixFrom(asset: asset)
        let fileName = fileNamePrefix + videoFileType.suffix
        return temporaryPath + fileName
    }
    
    static func writeImage(imageData: Data?, to filePath: String) throws {
        try imageData?.write(to: URL(fileURLWithPath: filePath))
    }
    
}

// MARK: Capture
public extension FileHelper {
    
    static func createCapturePhotoPath() -> String {
        return createCapturePath(suffix: ".jpg")
    }
    
    static func createCaptureVideoPath(fileType: CaptureVideoFileType) -> String {
        return createCapturePath(suffix: fileType.suffix)
    }
    
    static func createCapturePath(suffix: String) -> String {
        let directoryPath = temporaryPath + "Capture/"
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: directoryPath),
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = dateFormatter.string(from: Date()) + suffix
        return directoryPath  + fileName
    }
    
}

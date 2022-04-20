//
//  AssetFetchTool+Operation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit
import AVFoundation
import CoreMedia
import Photos

typealias AssetFetchOperationProgress = (Double) -> Void
typealias AssetFetchOperationResult = (Result<PhotoPickerResult, AssetFetchError>) -> Void
typealias AssetFetchAssetsResult = (Result<[PhotoPickerResult], AssetFetchError>) -> Void

extension AssetFetchTool {
    
    func requestAssets(assets: [AssetModel], progressHandle: AssetFetchOperationProgress? = nil, completionHandle: @escaping AssetFetchAssetsResult) {
        var resultArray: [PhotoPickerResult] = []
        for asset in assets {
            let progressClosure: AssetFetchOperationProgress = { progress in
                DispatchQueue.main.async {
                    progressHandle?(progress)
                }
            }
            let completionClosure: AssetFetchOperationResult = { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        resultArray.append(response)
                    case .failure(let error):
                        self.assetFetchOperations.cancelAllOperations()
                        completionHandle(.failure(error))
                    }
                    if resultArray.count == assets.count {
                        completionHandle(.success(resultArray))
                    }
                }
            }
            let operation = AssetFetchOperation(assetModel: asset, isOriginal: isOriginal, config: config, progress: progressClosure, completion: completionClosure)
            assetFetchOperations.addOperation(operation)
        }
        
    }
    
}

fileprivate class AssetFetchOperation: Operation {
    
    private let assetModel: AssetModel
    private let isOriginal: Bool
    private let config: WLPhotoConfig
    private var assetRequest: AssetFetchRequest?
    private let progress: AssetFetchOperationProgress?
    private let completion: AssetFetchOperationResult?
    
    private var _isExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    private var _isFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        _isFinished
    }
    
    private var _isCancelled = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    override var isCancelled: Bool {
        _isCancelled
    }
    
    init(assetModel: AssetModel,
         isOriginal: Bool,
         config: WLPhotoConfig,
         progress: AssetFetchOperationProgress? = nil,
         completion: AssetFetchOperationResult? = nil) {
        self.assetModel = assetModel
        self.isOriginal = isOriginal
        self.config = config
        self.progress = progress
        self.completion = completion
    }
    
    override func start() {
        super.start()
        if _isCancelled {
            finishAssetRequest()
            return
        }
        _isExecuting = true
        
        let options = AssetFetchOptions()
        options.imageDeliveryMode = .highQualityFormat
        if isOriginal {
            options.sizeOption = .original
        } else {
            options.sizeOption = .specify(config.pickerConfig.maximumPreviewSize)
        }
        options.progressHandler = { [weak self] progress in
            self?.progress?(progress)
        }
        
        switch assetModel.mediaType {
        case .photo:
            requestPhoto(options)
        case .livePhoto:
            requestLivePhoto(options)
        case .GIF:
            requestGIF(options)
        case .video:
            requestVideo(options)
        }
    }
    
    override func cancel() {
        super.cancel()
        if isExecuting {
            cancelAssetRequest()
        }
    }
    
    func finishAssetRequest() {
        _isFinished = true
        _isExecuting = false
    }
    
    func cancelAssetRequest() {
        finishAssetRequest()
        assetRequest?.cancel()
    }
}

// MARK: Request photo
extension AssetFetchOperation {
    
    func requestPhoto(_ options: AssetFetchOptions) {
        var currentPhoto: UIImage?
        switch (isOriginal, assetModel.hasEdit) {
        case (false, false):
            currentPhoto = assetModel.previewPhoto
        case (false, true):
            currentPhoto = assetModel.editedPhoto
        case (true, false):
            currentPhoto = assetModel.originalPhoto
        default: break
        }
        
        if let photo = currentPhoto {
            DispatchQueue.main.async { [weak self] in
                self?.finishRequestPhoto(photo)
            }
            return
        }
        
        assetRequest = AssetFetchTool.requestPhoto(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if self.isOriginal {
                    self.assetModel.originalPhoto = response.photo
                } else {
                    self.assetModel.previewPhoto = response.photo
                }
                if self.assetModel.hasEdit {
                    let editManager = EditManager(photo: response.photo, assetModel: self.assetModel)
                    guard let photo = editManager.drawOverlay(at: editManager.drawPhoto(), withCrop: true) else {
                        return
                    }
                    self.finishRequestPhoto(photo)
                } else {
                    self.finishRequestPhoto(response.photo)
                }
            case .failure(let error):
                self.completion?(.failure(error))
                self.finishAssetRequest()
            }
        }
    }
    
    func requestGIF(_ options: AssetFetchOptions) {
        assetRequest = AssetFetchTool.requestGIF(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.finishRequestPhoto(response.image, data: response.imageData)
            case .failure(let error):
                self.completion?(.failure(error))
                self.finishAssetRequest()
            }
        }
    }
    
    func finishRequestPhoto(_ photo: UIImage) {
        let data = photo.jpegData(compressionQuality: config.pickerConfig.jpgCompressionQuality)
        finishRequestPhoto(photo, data: data)
    }
    
    func finishRequestPhoto(_ photo: UIImage, data: Data?) {
        var fileURL: URL?
        if config.pickerConfig.exportImageURLWhenPick, let data = data {
            let filePath = FileHelper.createFilePathFrom(asset: assetModel)
            fileURL = URL(fileURLWithPath: filePath)
            do {
                try data.write(to: URL.init(fileURLWithPath: filePath))
            } catch {
                completion?(.failure(.failedToExportPhoto))
            }
        }
        if config.pickerConfig.saveEditedPhotoToAlbum, assetModel.hasEdit {
            AssetSaveManager.savePhoto(photo: photo)
        }
        let photoResult = PhotoPickerPhotoResult(photo: photo, photoURL: fileURL)
        completion?(.success(PhotoPickerResult(asset: assetModel, result: .photo(photoResult))))
        finishAssetRequest()
    }
    
}

// MARK: Request livePhoto
extension AssetFetchOperation {
    
    func requestLivePhoto(_ options: AssetFetchOptions) {
        assetRequest = AssetFetchTool.requestLivePhoto(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.analysisLivePhoto(response.livePhoto, options: options)
            case .failure(let error):
                self.completion?(.failure(error))
                self.finishAssetRequest()
            }
        }
    }
    
    func analysisLivePhoto(_ livePhoto: PHLivePhoto, options: AssetFetchOptions) {
        let results = PHAssetResource.assetResources(for: livePhoto)
        guard let pairedVideo = results.first(where: { $0.type == .pairedVideo }) else {
            finishAnalysisLivePhoto(livePhoto, videoURL: nil, options: options)
            return
        }
        
        let videoURL = URL(fileURLWithPath: FileHelper.createLivePhotoVideoPath())
        // 由于实况照片中的photoData可为空，所以不使用writeData方法获取封面图
        PHAssetResourceManager.default().writeData(for: pairedVideo, toFile: videoURL, options: nil) { [weak self] error in
            if error == nil {
                self?.finishAnalysisLivePhoto(livePhoto, videoURL: videoURL, options: options)
            } else {
                self?.finishAnalysisLivePhoto(livePhoto, videoURL: nil, options: options)
            }
        }
    }
    
    func finishAnalysisLivePhoto(_ livePhoto: PHLivePhoto, videoURL: URL?, options: AssetFetchOptions) {
        assetRequest = AssetFetchTool.requestPhoto(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let photoResult = PhotoPickerLivePhotoResult(livePhoto: livePhoto, photo: response.photo, videoURL: videoURL)
                self.completion?(.success(PhotoPickerResult(asset: self.assetModel, result: .livePhoto(photoResult))))
                self.finishAssetRequest()
            case .failure(let error):
                self.completion?(.failure(error))
                self.finishAssetRequest()
            }
        }
    }
    
}

// MARK: Request video
extension AssetFetchOperation {
    
    func requestVideo(_ options: AssetFetchOptions) {
        assetRequest = AssetFetchTool.requestAVAsset(for: self.assetModel.asset, options: options, completion: { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.finishRequestVideo(response, options: options)
            case .failure(let error):
                self.completion?(.failure(error))
                self.finishAssetRequest()
            }
        })
    }
    
    func finishRequestVideo(_ response: VideoFetchResponse, options: AssetFetchOptions) {
        if config.pickerConfig.exportVideoURLWhenPick {
            if isOriginal,
               config.pickerConfig.allowVideoSelectOriginal,
               let fileURL = assetModel.asset.locallyVideoFileURL {
                let result = PhotoPickerVideoResult(avasset: response.avasset, playerItem: response.playerItem, videoURL: fileURL)
                recudeVideoResult(result, options: options)
            } else {
                compressExportVideo(response, options: options)
            }
        } else {
            let result = PhotoPickerVideoResult(avasset: response.avasset, playerItem: response.playerItem)
            recudeVideoResult(result, options: options)
        }
    }
    
    func compressExportVideo(_ response: VideoFetchResponse, options: AssetFetchOptions) {
        let videoOutputPath = FileHelper.createVideoPathFrom(asset: assetModel, videoFileType: config.pickerConfig.videoExportFileType)
        let manager = VideoCompressManager(avAsset: response.avasset, outputPath: videoOutputPath)
        manager.compressVideo = !(isOriginal && config.pickerConfig.allowVideoSelectOriginal)
        manager.compressSize = config.pickerConfig.videoExportCompressSize
        manager.frameDuration = config.pickerConfig.videoExportFrameDuration
        manager.videoExportFileType = config.pickerConfig.videoExportFileType
        manager.exportVideo { progress in
            options.progressHandler?(progress)
        } completion: { [weak self] fileURL in
            guard let self = self else { return }
            if manager.error != nil {
                self.completion?(.failure(.failedToExportVideo))
                self.finishAssetRequest()
            } else {
                let result = PhotoPickerVideoResult(avasset: response.avasset, playerItem: response.playerItem, videoURL: fileURL)
                self.recudeVideoResult(result, options: options)
            }
        }
    }
    
    func recudeVideoResult(_ result: PhotoPickerVideoResult, options: AssetFetchOptions) {
        var videoResult = result
        assetRequest = AssetFetchTool.requestPhoto(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                videoResult.thumbnail = response.photo
                self.completion?(.success(PhotoPickerResult(asset: self.assetModel, result: .video(videoResult))))
                self.finishAssetRequest()
            case .failure(let error):
                self.completion?(.failure(error))
                self.finishAssetRequest()
            }
        }
    }
    
}

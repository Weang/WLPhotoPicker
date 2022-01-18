//
//  AssetFetchTool+Operation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit
import AVFoundation
import CoreMedia

public typealias AssetFetchOperationProgress = (Double) -> Void
public typealias AssetFetchOperationResult = (Result<AssetPickerResult, WLPhotoError>) -> Void
public typealias AssetFetchAssetsResult = (Result<[AssetPickerResult], WLPhotoError>) -> Void

extension AssetFetchTool {
    
    func requestAssets(assets: [AssetModel], progressHandle: AssetFetchOperationProgress? = nil, completionHandle: @escaping AssetFetchAssetsResult) {
        var resultArray: [AssetPickerResult] = []
        for asset in assets {
            let progressClosure: AssetFetchOperationProgress = { progress in
                progressHandle?(progress)
            }
            let completionClosure: AssetFetchOperationResult = { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    resultArray.append(response)
                case .failure(let error):
                    self.assetFetchQueue.cancelAllOperations()
                    completionHandle(.failure(error))
                }
                if resultArray.count == assets.count {
                    completionHandle(.success(resultArray))
                }
            }
            let operation = AssetFetchOperation(assetModel: asset,
                                                isOrigin: isOrigin,
                                                config: config,
                                                progress: progressClosure,
                                                completion: completionClosure)
            assetFetchQueue.addOperation(operation)
        }
        
    }
    
}

public class AssetFetchOperation: Operation {
    
    let assetModel: AssetModel
    let isOriginal: Bool
    let config: WLPhotoConfig
    var assetRequest: AssetFetchRequest?
    let progress: AssetFetchOperationProgress?
    let completion: AssetFetchOperationResult?
    
    private var _isExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    public override var isExecuting: Bool {
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
    
    public override var isFinished: Bool {
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
    
    public override var isCancelled: Bool {
        _isCancelled
    }
    
    init(assetModel: AssetModel,
         isOrigin: Bool,
         config: WLPhotoConfig,
         progress: AssetFetchOperationProgress? = nil,
         completion: AssetFetchOperationResult? = nil) {
        self.assetModel = assetModel
        self.isOriginal = isOrigin
        self.config = config
        self.progress = progress
        self.completion = completion
    }
    
    public override func start() {
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
        case .photo, .livePhoto:
            requestPhoto(options: options)
        case .GIF:
            requestGIF(options: options)
        case .video:
            requestVideo(options: options)
        }
    }
    
    func requestPhoto(options: AssetFetchOptions) {
        var currentPhoto: UIImage?
        switch (isOriginal, assetModel.hasEdit) {
        case (false, false):
            currentPhoto = assetModel.previewImage
        case (false, true):
            currentPhoto = assetModel.editedImage
        case (true, false):
            currentPhoto = assetModel.originalImage
        default: break
        }
        if let photo = currentPhoto {
            DispatchQueue.main.async { [weak self] in
                self?.finishRequestPhoto(photo)
            }
            return
        }
        
        assetRequest = AssetFetchTool.requestImage(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if self.assetModel.hasEdit {
                    self.assetModel.originalImage = response.image
                    EditManager.drawEditOriginalImageFrom(asset: self.assetModel, photoEditConfig: self.config.photoEditConfig) { [weak self] image in
                        if let image = image {
                            self?.finishRequestPhoto(image)
                        }
                    }
                } else {
                    self.finishRequestPhoto(response.image)
                }
            case .failure(let error):
                self.completion?(.failure(.fetchError(error)))
                self.finishAssetRequest()
            }
        }
    }
    
    func requestGIF(options: AssetFetchOptions) {
        assetRequest = AssetFetchTool.requestGIF(for: assetModel.asset, options: options) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.finishRequestImage(response.image, data: response.imageData)
            case .failure(let error):
                self.completion?(.failure(.fetchError(error)))
            }
            self.finishAssetRequest()
        }
    }
    
    func finishRequestPhoto(_ photo: UIImage) {
        let data = photo.jpegData(compressionQuality: config.pickerConfig.jpgCompressionQuality)
        finishRequestImage(photo, data: data)
    }
    
    func finishRequestImage(_ image: UIImage, data: Data?) {
        var fileURL: URL?
        if config.pickerConfig.saveImageToLocalWhenPick {
            let filePath = FileHelper.createFilePathFrom(asset: assetModel)
            fileURL = URL(fileURLWithPath: filePath)
            do {
                try FileHelper.writeImage(imageData: data, to: filePath)
            } catch {
                completion?(.failure(.fileHelper(.underlying(error))))
            }
        }
        if config.pickerConfig.saveEditedPhotoToAlbum, assetModel.hasEdit {
            AssetFetchTool.savePhoto(image: image) { _ in }
        }
        completion?(.success(AssetPickerResult(asset: assetModel, image: image, fileURL: fileURL)))
        if !_isFinished {
            finishAssetRequest()
        }
    }
    
    func requestVideo(options: AssetFetchOptions) {
        assetRequest = AssetFetchTool.requestAVAsset(for: self.assetModel.asset, options: options, completion: { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.finishRequestVideo(response, options: options)
            case .failure(let error):
                self.completion?(.failure(.fetchError(error)))
                self.finishAssetRequest()
            }
        })
    }
    
    func finishRequestVideo(_ response: VideoFetchResponse, options: AssetFetchOptions) {
        if self.config.pickerConfig.exportVideoToLocalWhenPick {
            let videoOutputPath = FileHelper.createVideoPathFrom(asset: assetModel, videoFileType: config.pickerConfig.videoExportFileType)
            let exportManager = VideoExportManager(avAsset: response.avasset, outputPath: videoOutputPath)
            exportManager.compressVideo = !(isOriginal && config.pickerConfig.videoExportOriginal)
            exportManager.compressSize = config.pickerConfig.videoExportCompressSize
            exportManager.frameDuration = config.pickerConfig.videoExportFrameDuration
            exportManager.videoExportFileType = config.pickerConfig.videoExportFileType
            exportManager.exportVideo { progress in
                options.progressHandler?(progress)
            } completion: { url in
                self.completion?(.success(AssetPickerResult(asset: self.assetModel,
                                                            playerItem: response.playerItem,
                                                            fileURL: url)))
                self.finishAssetRequest()
            }
        } else {
            completion?(.success(AssetPickerResult(asset: assetModel,
                                                   playerItem: response.playerItem)))
            finishAssetRequest()
        }
    }
    
    public override func cancel() {
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

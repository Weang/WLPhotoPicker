//
//  CameraManager.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import AssetsLibrary
import AVFoundation
import VideoToolbox

public protocol CaptureManagerDelegate: AnyObject {
    func captureManager(_ captureManager: CaptureManager, didOccurredError error: CaptureError)
    func captureManager(_ captureManager: CaptureManager, finishTakingPhoto photo: UIImage?)
}

public extension CaptureManagerDelegate {
    func captureManager(_ captureManager: CaptureManager, didOccurredError error: CaptureError) { }
    func captureManager(_ captureManager: CaptureManager, finishTakingPhoto photo: UIImage?) { }
}

public class CaptureManager: NSObject {
    
    weak var delegate: CaptureManagerDelegate?
    
    let captureSession = AVCaptureSession()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var videoDeviceInput: AVCaptureDeviceInput?
    var audioDeviceInput: AVCaptureDeviceInput?
    
    var assetWriter: AVAssetWriter?
    var assetWriterAudioInput: AVAssetWriterInput?
    var assetWriterVideoInput: AVAssetWriterInput?
    
    let videoDataOutput = AVCaptureVideoDataOutput()
    let audioDataOutput = AVCaptureAudioDataOutput()
    let photoOutput = AVCapturePhotoOutput()
    
    let sessionQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Session")
    let videoDataOutputQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Video")
    let audioDataOutputQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Audio")
    let assetWriterQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Writer")
    
    var isRecording: Bool = false
    var isFocusing: Bool = false
    var videoCurrentZoom: Double = 1.0
    
    var currentOrientation: UIInterfaceOrientation = .portrait
    let deviceOrientation = DeviceOrientation()
    
    let pickerConfig: WLPhotoConfig
    
    public init(pickerConfig: WLPhotoConfig) {
        self.pickerConfig = pickerConfig
        super.init()
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        deviceOrientation.delegate = self
        
        sessionQueue.async { [weak self] in
            self?.captureSession.beginConfiguration()
            self?.setupCapture()
            self?.captureSession.commitConfiguration()
            self?.focusAt(CGPoint(x: 0.5, y: 0.5))
        }
    }
    
    func setupCapture() {
        let sessionPreset = pickerConfig.captureConfig.captureSessionPreset.avSessionPreset
        if (captureSession.canSetSessionPreset(sessionPreset)) {
            captureSession.sessionPreset = sessionPreset
        }
        
        setupDataOut()
        setupCameraDevice(position: .back)
        setupAudioDevice()
    }
    
    func setupCameraDevice(position: AVCaptureDevice.Position) {
        if let videoDeviceInput = self.videoDeviceInput {
            captureSession.removeInput(videoDeviceInput)
        }
        guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                 mediaType: .video,
                                                                 position: position).devices.first,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                  delegate?.captureManager(self, didOccurredError: .deviceInitializeError)
                  return
              }
        self.videoDeviceInput = videoDeviceInput
        
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }
        
        try? videoDevice.lockForConfiguration()
        
        videoDevice.isSubjectAreaChangeMonitoringEnabled = true
        if videoDevice.isSmoothAutoFocusSupported {
            videoDevice.isSmoothAutoFocusEnabled = true
        }
        
        if let availableActiveFormat = videoDevice.availableActiveFormat(for: pickerConfig) {
            videoDevice.activeFormat = availableActiveFormat
            let frameDuration = CMTime(value: 1, timescale: CMTimeScale(pickerConfig.captureConfig.captureVideoFrameRate))
            videoDevice.activeVideoMinFrameDuration = frameDuration
            videoDevice.activeVideoMaxFrameDuration = frameDuration
        }
        
        if let connection = videoDataOutput.connection(with: .video) {
            let stabilizationMode = pickerConfig.captureConfig.captureVideoStabilizationMode.avPreferredVideoStabilizationMode
            connection.preferredVideoStabilizationMode = stabilizationMode
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = position == .front
            }
        }
        
        videoDevice.unlockForConfiguration()
    }
    
    func setupAudioDevice() {
        guard let audioDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
                                                                 mediaType: .audio,
                                                                 position: .unspecified).devices.first,
              let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {
                  delegate?.captureManager(self, didOccurredError: .deviceInitializeError)
                  return
              }
        self.audioDeviceInput = audioDeviceInput
        if captureSession.canAddInput(audioDeviceInput) {
            captureSession.addInput(audioDeviceInput)
        }
    }
    
    func setupDataOut() {
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        audioDataOutput.setSampleBufferDelegate(self, queue: audioDataOutputQueue)
        if captureSession.canAddOutput(audioDataOutput) {
            captureSession.addOutput(audioDataOutput)
        }
        
        photoOutput.isHighResolutionCaptureEnabled = true
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }
    
    func switchCamera() {
        if isRecording { return }
        
        guard let videoDeviceInput = self.videoDeviceInput else { return }
        let currentPosition = videoDeviceInput.device.position
        var toChangePosition = AVCaptureDevice.Position.front
        if currentPosition == .front {
            toChangePosition = .back
        }
        
        sessionQueue.async { [weak self] in
            self?.captureSession.beginConfiguration()
            self?.setupCameraDevice(position: toChangePosition)
            self?.captureSession.commitConfiguration()
        }
    }
    
    func setupPreviewLayer(to superView: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = superView.layer.bounds
        superView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    func starRunning() {
        deviceOrientation.startUpdates()
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopRunning() {
        deviceOrientation.stopUpdates()
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func focusAt(_ point: CGPoint) {
        lockVideoDeviceForConfiguration { [weak self] devide in
            guard let previewLayer = self?.previewLayer else {
                return
            }
            let cameraPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
            
            if devide.isFocusPointOfInterestSupported {
                devide.focusPointOfInterest = cameraPoint
            }
            if devide.isFocusModeSupported(.continuousAutoFocus) {
                devide.focusMode = .continuousAutoFocus
            }
            if devide.isExposurePointOfInterestSupported {
                devide.exposurePointOfInterest = cameraPoint
            }
            if devide.isExposureModeSupported(.continuousAutoExposure) {
                devide.exposureMode = .continuousAutoExposure
            }
        }
    }
    
    func prepareForZoom() {
        guard let videoDeviceInput = self.videoDeviceInput else {
            return
        }
        videoCurrentZoom = Double(videoDeviceInput.device.videoZoomFactor)
    }
    
    func zoom(_ mulriple: Double) {
        guard let videoDeviceInput = self.videoDeviceInput else {
            return
        }
        let videoMaxZoomFactor = min(5, videoDeviceInput.device.activeFormat.videoMaxZoomFactor)
        let toZoomFactory = max(1, videoCurrentZoom * mulriple)
        let finalZoomFactory = min(toZoomFactory, videoMaxZoomFactor)
        lockVideoDeviceForConfiguration { device in
            device.videoZoomFactor = finalZoomFactory
        }
    }
    
    func lockVideoDeviceForConfiguration(_ closure: (AVCaptureDevice) -> ()) {
        guard let videoDeviceInput = self.videoDeviceInput else {
            return
        }
        let captureDevice = videoDeviceInput.device
        try? captureDevice.lockForConfiguration()
        closure(captureDevice)
        captureDevice.unlockForConfiguration()
    }
    
    // 拍照调用方法
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = pickerConfig.captureConfig.captureFlashMode.avFlashMode
        settings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startRecordingVideo() {
        sessionQueue.async { [weak self] in
            self?.initializeVideoWriter()
            self?.isRecording = true
        }
    }
    
    func initializeVideoWriter() {
        let fileType = pickerConfig.captureConfig.captureFileType
        let videoPath = FileHelper.createCaptureVideoPath(fileType: pickerConfig.captureConfig.captureFileType)
        let fileUrl = URL(fileURLWithPath: videoPath)
        
        guard let assetWriter = try? AVAssetWriter(outputURL: fileUrl, fileType: fileType.avFileType) else {
            delegate?.captureManager(self, didOccurredError: .fileWriteError)
            return
        }
        
        let rotate = OrientationHelper.videoRotateWith(currentOrientation)
        let outputSettings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: fileType.avFileType)
        
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        assetWriterVideoInput.transform = CGAffineTransform(rotationAngle: CGFloat(rotate))
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        if assetWriter.canAdd(assetWriterVideoInput) {
            assetWriter.add(assetWriterVideoInput)
        }
        self.assetWriterVideoInput = assetWriterVideoInput
        
        let audioOutputSettings = audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: fileType.avFileType)
        let assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        if assetWriter.canAdd(assetWriterAudioInput) {
            assetWriter.add(assetWriterAudioInput)
        }
        self.assetWriterAudioInput = assetWriterAudioInput
        
        self.assetWriter = assetWriter
    }
    
    func stopRecordingVideo(completion: @escaping (URL) -> ()) {
        if !isRecording { return }
        isRecording = false
        assetWriterAudioInput?.markAsFinished()
        assetWriterVideoInput?.markAsFinished()
        guard let outputURL = assetWriter?.outputURL else {
            return
        }
        assetWriter?.finishWriting { [weak self] in
            guard let self = self else { return }
            self.assetWriter = nil
            self.assetWriterVideoInput = nil
            self.assetWriterAudioInput = nil
            DispatchQueue.main.async {
                completion(outputURL)
            }
        }
    }
    
}

extension CaptureManager: DeviceOrientationDelegate {
    
    func deviceOrientation(_ deviceOrientation: DeviceOrientation, didUpdate orientation: UIInterfaceOrientation) {
        currentOrientation = orientation
    }
    
}

extension CaptureManager: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation(),
              let photo = OrientationHelper.rotateImage(photoData: photoData,
                                                        orientation: currentOrientation,
                                                        aspectRatio: pickerConfig.captureConfig.captureAspectRatio) else {
                  return
              }
        delegate?.captureManager(self, finishTakingPhoto: photo)
    }
    
}

extension CaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRecording else { return }
        
        if output.isKind(of: AVCaptureVideoDataOutput.self) {
            if self.assetWriter?.status == .unknown {
                self.assetWriter?.startWriting()
                self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            }
            if self.assetWriterVideoInput?.isReadyForMoreMediaData ?? false {
                self.assetWriterVideoInput?.append(sampleBuffer)
            }
        }
        
        if output.isKind(of: AVCaptureAudioDataOutput.self) {
            if self.assetWriterAudioInput?.isReadyForMoreMediaData ?? false {
                self.assetWriterAudioInput?.append(sampleBuffer)
            }
        }
    }
    
}

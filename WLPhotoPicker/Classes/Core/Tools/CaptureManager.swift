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
    func captureManager(_ captureManager: CaptureManager, finishTakingVideo url: URL)
}

public extension CaptureManagerDelegate {
    func captureManager(_ captureManager: CaptureManager, didOccurredError error: CaptureError) { }
    func captureManager(_ captureManager: CaptureManager, finishTakingPhoto photo: UIImage?) { }
    func captureManager(_ captureManager: CaptureManager, finishTakingVideo url: URL) { }
}

public class CaptureManager: NSObject {
    
    weak var delegate: CaptureManagerDelegate?
    
    private let sessionQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Session")
    private let videoDataOutputQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Video")
    private let audioDataOutputQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Audio")
    private let assetWriterQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.CameraManager.Writer")
    
    private let captureSession = AVCaptureSession()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    
    private let movieFileOutput = AVCaptureMovieFileOutput()
    private let photoOutput = AVCapturePhotoOutput()
    
    private var isFocusing: Bool = false
    private var videoCurrentZoom: Double = 1.0
    
    private var currentOrientation: AVCaptureVideoOrientation = .portrait
    private let deviceOrientation = DeviceOrientation()
    
    private let pickerConfig: WLPhotoConfig
    
    public init(pickerConfig: WLPhotoConfig, delegate: CaptureManagerDelegate?) {
        self.pickerConfig = pickerConfig
        self.delegate = delegate
        super.init()
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        deviceOrientation.delegate = self
        
        sessionQueue.async { [weak self] in
            self?.setupCapture()
            self?.focusAt(CGPoint(x: 0.5, y: 0.5))
        }
    }
    
    private func setupCapture() {
        if TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1 {
            delegate?.captureManager(self, didOccurredError: .simulator)
            return
        }
        captureSession.beginConfiguration()
        
        let sessionPreset = pickerConfig.captureConfig.captureSessionPreset.avSessionPreset
        if (captureSession.canSetSessionPreset(sessionPreset)) {
            captureSession.sessionPreset = sessionPreset
        } else {
            captureSession.sessionPreset = CaptureSessionPreset.hd1920x1080.avSessionPreset
        }
        
        setupDataOutput()
        setupCameraDevice(position: .back)
        setupAudioDevice()
        
        captureSession.commitConfiguration()
    }
    
    private func setupDataOutput() {
        photoOutput.isHighResolutionCaptureEnabled = true
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        movieFileOutput.movieFragmentInterval = .invalid
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
        }
    }
    
    private func setupCameraDevice(position: AVCaptureDevice.Position) {
        if let videoDeviceInput = self.videoDeviceInput {
            captureSession.removeInput(videoDeviceInput)
        }
        guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                 mediaType: .video,
                                                                 position: position).devices.first,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                  delegate?.captureManager(self, didOccurredError: .failedToInitializeCameraDevice)
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
        
        if let connection = movieFileOutput.connection(with: .video) {
            let stabilizationMode = pickerConfig.captureConfig.captureVideoStabilizationMode.avPreferredVideoStabilizationMode
            connection.preferredVideoStabilizationMode = stabilizationMode
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = position == .front
            }
        }
        
        videoDevice.unlockForConfiguration()
    }
    
    private func setupAudioDevice() {
        guard let audioDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
                                                                 mediaType: .audio,
                                                                 position: .unspecified).devices.first,
              let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {
                  delegate?.captureManager(self, didOccurredError: .failedToInitializeAudioDevice)
                  return
              }
        self.audioDeviceInput = audioDeviceInput
        if captureSession.canAddInput(audioDeviceInput) {
            captureSession.addInput(audioDeviceInput)
        }
    }
    
    public func setupPreviewLayer(to superView: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = superView.layer.bounds
        superView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    public func starRunning() {
        deviceOrientation.startUpdates()
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    public func stopRunning() {
        deviceOrientation.stopUpdates()
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    deinit {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: Capture
public extension CaptureManager {
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = pickerConfig.captureConfig.captureFlashMode.avFlashMode
        settings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startRecordingVideo() {
        let videoPath = FileHelper.createCaptureVideoPath(fileType: pickerConfig.captureConfig.captureFileType)
        let fileUrl = URL(fileURLWithPath: videoPath)
        let connection = movieFileOutput.connection(with: .video)
        connection?.videoOrientation = currentOrientation
        movieFileOutput.startRecording(to: fileUrl, recordingDelegate: self)
    }
    
    func stopRecordingVideo() {
        LoadingHUD.shared.showLoading()
        movieFileOutput.stopRecording()
    }
}

// MARK: Configuration
extension CaptureManager {
    
    public func switchCamera() {
        if movieFileOutput.isRecording { return }
        
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
    
    public func prepareForZoom() {
        guard let videoDeviceInput = self.videoDeviceInput else {
            return
        }
        videoCurrentZoom = Double(videoDeviceInput.device.videoZoomFactor)
    }
    
    public func focusAt(_ point: CGPoint) {
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
    
    public func zoom(_ mulriple: Double) {
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
    
    private func lockVideoDeviceForConfiguration(_ closure: (AVCaptureDevice) -> ()) {
        guard let videoDeviceInput = self.videoDeviceInput else {
            return
        }
        let captureDevice = videoDeviceInput.device
        try? captureDevice.lockForConfiguration()
        closure(captureDevice)
        captureDevice.unlockForConfiguration()
    }
    
}

extension CaptureManager: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation(),
              let photo = OrientationHelper.rotateImage(photoData: photoData,
                                                        orientation: currentOrientation) else {
                  return
              }
        delegate?.captureManager(self, finishTakingPhoto: photo)
    }
    
}

extension CaptureManager: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        LoadingHUD.shared.hideLoading()
        if let error = error {
            delegate?.captureManager(self, didOccurredError: .underlying(error))
        } else {
            delegate?.captureManager(self, finishTakingVideo: outputFileURL)
        }
    }
    
}

extension CaptureManager: DeviceOrientationDelegate {
    
    func deviceOrientation(_ deviceOrientation: DeviceOrientation, didUpdate orientation: AVCaptureVideoOrientation) {
        currentOrientation = orientation
    }
    
}
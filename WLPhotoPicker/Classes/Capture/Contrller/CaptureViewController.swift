//
//  CaptureViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import Photos

public protocol CaptureViewControllerDelegate: AnyObject {
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingPhoto photo: UIImage)
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL)
}

public extension CaptureViewControllerDelegate {
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingPhoto photo: UIImage) { }
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL) { }
}

public class CaptureViewController: UIViewController {
    
    private var captureManager: CaptureManager?
    private let controlView: CaptureControlView
    private let captureConfig: CaptureConfig
    private let photoEditConfig: PhotoEditConfig?
    
    public weak var delegate: CaptureViewControllerDelegate?
    
    private var isPermissionReady = false
    
    public init(captureConfig: CaptureConfig, photoEditConfig: PhotoEditConfig? = nil) {
        self.captureConfig = captureConfig
        self.photoEditConfig = photoEditConfig
        self.controlView = CaptureControlView(captureConfig: captureConfig)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var prefersStatusBarHidden: Bool {
        true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        PermissionProvider.request([.camera, .microphone]) { [weak self] type, status in
            guard status == .authorized else {
                self?.showError(type == .camera ? .cameraPermissionDenied : .microphonePermissionDenied)
                return
            }
            self?.setupManager()
            self?.startRunning()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRunning()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        
        controlView.delegate = self
        view.addSubview(controlView)
        controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.layoutSubviews()
        controlView.layoutSubviews()
    }
    
    private func setupManager() {
        captureManager = CaptureManager(captureConfig: captureConfig, delegate: self)
        captureManager?.setupPreviewLayer(to: controlView.previewContentView)
    }
    
    private func startRunning() {
        if let _ = captureManager {
            controlView.showRunningAnimation()
            controlView.showFocusAnimationAt(point: CGPoint(x: controlView.previewContentView.width * 0.5,
                                                            y: controlView.previewContentView.height * 0.5))
        }
        captureManager?.starRunning()
    }
    
    private func stopRunning() {
        if let _ = captureManager {
            controlView.showStopRunningAnimation()
        }
        captureManager?.stopRunning()
    }
    
    private func showError(_ error: CaptureError) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: BundleHelper.localizedString(.Confirm), style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        stopRunning()
    }
}

// MARK: CaptureManagerDelegate
extension CaptureViewController: CaptureManagerDelegate {
    
    public func captureManager(_ captureManager: CaptureManager, didOccurredError error: CaptureError) {
        showError(error)
    }
    
    public func captureManager(_ captureManager: CaptureManager, finishTakingPhoto photo: UIImage) {
        if let photoEditConfig = self.photoEditConfig {
            let editVC = PhotoEditViewController(photo: photo, photoEditConfig: photoEditConfig)
            editVC.delegate = self
            present(editVC, animated: false, completion: nil)
        } else {
            let previewVC = CapturePreviewViewController(previewPhoto: photo)
            previewVC.delegate = self
            present(previewVC, animated: false, completion: nil)
        }
    }
    
    public func captureManager(_ captureManager: CaptureManager, finishTakingVideo url: URL) {
        let previewVC = CapturePreviewViewController(videoUrl: url)
        previewVC.delegate = self
        self.present(previewVC, animated: false, completion: nil)
    }
    
}

// MARK: WLCameraControlDelegate
extension CaptureViewController: WLCameraControlDelegate {
    
    func cameraControlDidClickExit(_ controlView: CaptureControlView) {
        dismiss(animated: true, completion: nil)
    }
    
    func cameraControlDidClickChangeCamera(_ controlView: CaptureControlView) {
        captureManager?.switchCamera()
    }
    
    func cameraControl(_ controlView: CaptureControlView, didFocusAt point: CGPoint) {
        captureManager?.focusAt(point)
    }
    
    func controlViewDidTakePhoto(_ controlView: CaptureControlView) {
        captureManager?.capturePhoto()
    }
    
    func controlViewDidBeginTakingVideo(_ controlView: CaptureControlView) {
        captureManager?.startRecordingVideo()
    }
    
    func controlViewDidEndTakingVideo(_ controlView: CaptureControlView) {
        captureManager?.stopRecordingVideo()
    }
    
    func cameraControlDidPrepareForZoom(_ controlView: CaptureControlView) {
        captureManager?.prepareForZoom()
    }
    
    func controlView(_ controlView: CaptureControlView, didChangeVideoZoom zoomScale: Double) {
        captureManager?.zoom(zoomScale)
    }
    
}

// MARK: CapturePreviewViewControllerDelegate
extension CaptureViewController: CapturePreviewViewControllerDelegate {
    
    func previewViewController(_ controller: CapturePreviewViewController, didClickDoneButtonWithPhoto photo: UIImage) {
        delegate?.captureViewController(self, didFinishTakingPhoto: photo)
    }
    
    func previewViewController(_ controller: CapturePreviewViewController, didClickDoneButtonWithVideoUrl url: URL) {
        delegate?.captureViewController(self, didFinishTakingVideo: url)
    }
}

// MARK: PhotoEditViewControllerDelegate
extension CaptureViewController: PhotoEditViewControllerDelegate {
    
    public func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?) {
        guard let editedPhoto = photo else {
            return
        }
        delegate?.captureViewController(self, didFinishTakingPhoto: editedPhoto)
    }
    
}

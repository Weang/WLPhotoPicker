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

public class CaptureViewController: UIViewController {
    
    private var captureManager: CaptureManager!
    private let controlView: CaptureControlView
    private let config: WLPhotoConfig
    
    weak var delegate: CaptureViewControllerDelegate?
    
    public init(config: WLPhotoConfig) {
        self.config = config
        self.controlView = CaptureControlView(pickerConfig: config)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
        captureManager = CaptureManager(pickerConfig: config, delegate: self)
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
        setupManager()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureManager.starRunning()
        controlView.showRunningAnimation()
        controlView.showFocusAnimationAt(point: CGPoint(x: controlView.previewContentView.width * 0.5,
                                                        y: controlView.previewContentView.height * 0.5))
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureManager.stopRunning()
        controlView.showStopRunningAnimation()
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
        captureManager.delegate = self
        captureManager.setupPreviewLayer(to: controlView.previewContentView)
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        captureManager.stopRunning()
    }
}

// MARK: CaptureManagerDelegate
extension CaptureViewController: CaptureManagerDelegate {
    
    public func captureManager(_ captureManager: CaptureManager, didOccurredError error: CaptureError) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func captureManager(_ captureManager: CaptureManager, finishTakingPhoto photo: UIImage?) {
        if config.pickerConfig.allowEditPhoto {
            let editVC = PhotoEditViewController(photo: photo, photoEditConfig: config.photoEditConfig)
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
        captureManager.switchCamera()
    }
    
    func cameraControl(_ controlView: CaptureControlView, didFocusAt point: CGPoint) {
        captureManager.focusAt(point)
    }
    
    func controlViewDidTakePhoto(_ controlView: CaptureControlView) {
        captureManager.capturePhoto()
    }
    
    func controlViewDidBeginTakingVideo(_ controlView: CaptureControlView) {
        captureManager.startRecordingVideo()
    }
    
    func controlViewDidEndTakingVideo(_ controlView: CaptureControlView) {
        captureManager.stopRecordingVideo()
    }
    
    func cameraControlDidPrepareForZoom(_ controlView: CaptureControlView) {
        captureManager.prepareForZoom()
    }
    
    func controlView(_ controlView: CaptureControlView, didChangeVideoZoom zoomScale: Double) {
        captureManager.zoom(zoomScale)
    }
    
}

// MARK: CapturePreviewViewControllerDelegate
extension CaptureViewController: CapturePreviewViewControllerDelegate {
    
    func previewViewController(_ controller: CapturePreviewViewController, didClickDoneButtonWithPhoto photo: UIImage) {
        delegate?.captureViewController(self, didFinishTakingPhoto: photo)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func previewViewController(_ controller: CapturePreviewViewController, didClickDoneButtonWithVideoUrl url: URL) {
        delegate?.captureViewController(self, didFinishTakingVideo: url)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: PhotoEditViewControllerDelegate
extension CaptureViewController: PhotoEditViewControllerDelegate {
    
    public func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?) {
        guard let editedPhoto = photo else {
            return
        }
        delegate?.captureViewController(self, didFinishTakingPhoto: editedPhoto)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

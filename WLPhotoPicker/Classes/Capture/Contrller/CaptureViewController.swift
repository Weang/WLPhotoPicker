//
//  CaptureViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit
import Photos

protocol CaptureViewControllerDelegate: AnyObject {
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingPhoto photo: UIImage)
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL)
}

public class CaptureViewController: UIViewController {

    let captureManager: CaptureManager
    let controlView: CaptureControlView
    let config: WLPhotoConfig
    
    weak var delegate: CaptureViewControllerDelegate?
    
    public init(config: WLPhotoConfig) {
        self.config = config
        self.controlView = CaptureControlView(pickerConfig: config)
        self.captureManager = CaptureManager(pickerConfig: config)
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
        setupManager()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1 {
            return
        }
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
    
    func setupView() {
        view.backgroundColor = .black
        
        controlView.delegate = self
        view.addSubview(controlView)
        controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.layoutSubviews()
        controlView.layoutSubviews()
    }
    
    func setupManager() {
        captureManager.delegate = self
        captureManager.setupPreviewLayer(to: controlView.previewContentView)
    }
    
    deinit {
        captureManager.stopRunning()
    }
}

extension CaptureViewController: CaptureManagerDelegate {
    
    public func captureManager(_ captureManager: CaptureManager, didOccurredError error: CaptureError) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
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
    
}

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

extension CaptureViewController: WLCameraControlDelegate {
    
    public func cameraControlDidClickExit(_ controlView: CaptureControlView) {
        dismiss(animated: true, completion: nil)
    }
    
    public func cameraControlDidClickChangeCamera(_ controlView: CaptureControlView) {
        captureManager.switchCamera()
    }
    
    public func cameraControl(_ controlView: CaptureControlView, didFocusAt point: CGPoint) {
        captureManager.focusAt(point)
    }
    
    public func controlViewDidTakePhoto(_ controlView: CaptureControlView) {
        captureManager.capturePhoto()
    }
    
    public func controlViewDidBeginTakingVideo(_ controlView: CaptureControlView) {
        captureManager.startRecordingVideo()
    }
    
    public func controlViewDidEndTakingVideo(_ controlView: CaptureControlView) {
        captureManager.stopRecordingVideo { [weak self] url in
            let previewVC = CapturePreviewViewController(videoUrl: url)
            previewVC.delegate = self
            self?.present(previewVC, animated: false, completion: nil)
        }
    }
    
    public func cameraControlDidPrepareForZoom(_ controlView: CaptureControlView) {
        captureManager.prepareForZoom()
    }
    
    public func controlView(_ controlView: CaptureControlView, didChangeVideoZoom zoomScale: Double) {
        captureManager.zoom(zoomScale)
    }

}

extension CaptureViewController: PhotoEditViewControllerDelegate {
    
    func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?) {
        guard let editedPhoto = photo else {
            return
        }
        delegate?.captureViewController(self, didFinishTakingPhoto: editedPhoto)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

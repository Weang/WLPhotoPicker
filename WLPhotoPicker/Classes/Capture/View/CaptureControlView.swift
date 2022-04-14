//
//  CaptureControlView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/1.
//

import UIKit

protocol WLCameraControlDelegate: AnyObject {
    
    // exit
    func cameraControlDidClickExit(_ controlView: CaptureControlView)
    
    // camera
    func cameraControlDidClickChangeCamera(_ controlView: CaptureControlView)
    func cameraControlDidPrepareForZoom(_ controlView: CaptureControlView)
    func cameraControl(_ controlView: CaptureControlView, didFocusAt point: CGPoint)
    
    // photo
    func controlViewDidTakePhoto(_ controlView: CaptureControlView)
    
    // video
    func controlViewDidBeginTakingVideo(_ controlView: CaptureControlView)
    func controlViewDidEndTakingVideo(_ controlView: CaptureControlView)
    func controlView(_ controlView: CaptureControlView, didChangeVideoZoom zoomScale: Double)
}

class CaptureControlView: UIView {
    
    weak var delegate: WLCameraControlDelegate?
    
    let previewContentView = UIView()
    private let tipLabel = UILabel()
    private let cameraButton = CaptureCameraButton()
    private let cancelButton = UIButton()
    private let changeCameraButton = UIButton()
    private let focusImageView = UIImageView()
    private var isFocusing: Bool = false
    
    private var videoTimer: Timer?
    private var videoRecordTime: Double = 0
    
    private let captureConfig: CaptureConfig
    
    public init(captureConfig: CaptureConfig) {
        self.captureConfig = captureConfig
        super.init(frame: .zero)
        
        setupView()
    }
    
    private func setupView() {
        previewContentView.layer.opacity = 0
        previewContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusTapGes(_:))))
        previewContentView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomPinchGes(_:))))
        previewContentView.backgroundColor = .clear
        addSubview(previewContentView)
        previewContentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tapGesture.isEnabled = captureConfig.allowTakingPhoto
        cameraButton.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPressGesture.isEnabled = captureConfig.allowTakingVideo
        longPressGesture.minimumPressDuration = 0.2
        cameraButton.addGestureRecognizer(longPressGesture)
        addSubview(cameraButton)
        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-60 - keyWindowSafeAreaInsets.bottom)
        }
        
        tipLabel.isHidden = true
        var text = ""
        if captureConfig.allowTakingPhoto {
            text.append("轻触拍照")
        }
        if captureConfig.allowTakingVideo{
            if text.count > 0 {
                text.append(",")
            }
            text.append("按住摄像")
        }
        tipLabel.text = text
        tipLabel.font = UIFont.systemFont(ofSize: 13)
        tipLabel.textColor = .white
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(cameraButton.snp.top).offset(-20)
        }
        
        cancelButton.tintColor = .white
        cancelButton.setImage(BundleHelper.imageNamed("capture_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton.snp.centerY)
            make.right.equalTo(cameraButton.snp.centerX).multipliedBy(0.5)
        }
        
        changeCameraButton.tintColor = .white
        changeCameraButton.setImage(BundleHelper.imageNamed("capture_rotate_camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
        changeCameraButton.addTarget(self, action: #selector(changeCameraButtonClick), for: .touchUpInside)
        addSubview(changeCameraButton)
        changeCameraButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton.snp.centerY)
            make.left.equalTo(cameraButton.snp.centerX).multipliedBy(1.5)
        }
        
        focusImageView.isHidden = true
        focusImageView.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        focusImageView.image = BundleHelper.imageNamed("capture_focus")?.withRenderingMode(.alwaysTemplate)
        focusImageView.tintColor = .green
        addSubview(focusImageView)
        
        layoutSubviews()
    }
    
    func showRunningAnimation() {
        self.previewContentView.isHidden = false
        previewContentView.layer.opacity = 1
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.6
        previewContentView.layer.add(animation, forKey: nil)
        tipLabel.isHidden = false
        perform(#selector(hideTipLabel), with: nil, afterDelay: 2)
    }
    
    func showStopRunningAnimation() {
        self.previewContentView.layer.opacity = 0
        self.previewContentView.isHidden = true
    }
    
    @objc func hideTipLabel() {
        UIView.animate(withDuration: 0.6) {
            self.tipLabel.alpha = 0
        } completion: { _ in
            self.tipLabel.isHidden = true
            self.tipLabel.alpha = 1
        }
    }
    
    @objc private func zoomPinchGes(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        if gesture.state == .began {
            delegate?.cameraControlDidPrepareForZoom(self)
        }
        delegate?.controlView(self, didChangeVideoZoom: gesture.scale)
    }
    
    @objc private func focusTapGes(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: previewContentView)
        showFocusAnimationAt(point: location)
    }
    
    func showFocusAnimationAt(point: CGPoint) {
        if isFocusing {
            return
        }
        isFocusing = true
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber(value: 1.0)
        animation.toValue = NSNumber(value: 0.1)
        animation.autoreverses = true
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.delegate = self
        focusImageView.layer.add(animation, forKey: nil)
        
        focusImageView.center = previewContentView.convert(point, to: focusImageView.superview)
        focusImageView.isHidden = false
        focusImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.2) {
            self.focusImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        delegate?.cameraControl(self, didFocusAt: point)
    }
    
    @objc private func cancelButtonClick() {
        delegate?.cameraControlDidClickExit(self)
    }
    
    @objc private func tapGesture() {
        delegate?.controlViewDidTakePhoto(self)
    }
    
    @objc private func longPressGesture(_ res: UIGestureRecognizer) {
        switch res.state {
        case .began:
            longPressBegin()
            delegate?.cameraControlDidPrepareForZoom(self)
        case .changed:
            let pointY = res.location(in: cameraButton).y
            var zoom = -pointY / (Double(UIScreen.width) * 0.15) + 1
            if pointY > 0 {
                zoom = 1
            }
            delegate?.controlView(self, didChangeVideoZoom: zoom)
        default:
            longPressEnd()
        }
    }
    
    private func longPressBegin() {
        cameraButton.showBeginAnimation()
        videoTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timeRecord), userInfo: nil, repeats: true)
        delegate?.controlViewDidBeginTakingVideo(self)
    }
    
    private func longPressEnd() {
        videoTimer?.invalidate()
        videoTimer = nil
        videoRecordTime = 0
        cameraButton.showEndAnimation()
        
        delegate?.controlViewDidEndTakingVideo(self)
    }
    
    @objc private func timeRecord() {
        videoRecordTime += 0.1
        let progress = videoRecordTime / captureConfig.captureMaximumVideoDuration
        if progress > 1 {
            longPressEnd()
        } else {
            cameraButton.updateProgress(progress)
        }
    }
    
    @objc private func changeCameraButtonClick() {
        delegate?.cameraControlDidClickChangeCamera(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CaptureControlView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.focusImageView.alpha = 0
        }) { _ in
            self.isFocusing = false
            self.focusImageView.isHidden = true
        }
    }
    
}

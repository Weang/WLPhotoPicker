//
//  AssetPreviewLivePhotoCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit
import PhotosUI

class AssetPreviewLivePhotoCell: AssetPreviewCell {
    
    private let livePhotoTipView = AssetPreviewLivePhotoView()
    private let livePhotoView = PHLivePhotoView()
    
    override var isShowToolBar: Bool {
        didSet {
            livePhotoTipView.isHidden = !isShowToolBar
        }
    }
    
    override func setupView() {
        super.setupView()
        
        livePhotoView.isHidden = true
        livePhotoView.playbackGestureRecognizer.isEnabled = false
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.delegate = self
        assetImageView.addSubview(livePhotoView)
        
        contentView.addSubview(livePhotoTipView)
        livePhotoTipView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(keyWindowSafeAreaInsets.top + 52)
        }
    }
    
    override func setupGesture() {
        super.setupGesture()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(livePhotoLongPress(_:)))
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.minimumPressDuration = 0.2
        contentScrollView.addGestureRecognizer(longPressGesture)
    }
    
    override func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        self.model = model
        
        cancelCurrentRequest()
        layoutImage(thumbnail)
        requestImage(model, pickerConfig: pickerConfig)
    }
    
    override func requestImage(_ model: AssetModel, pickerConfig: PickerConfig) {
        let options = AssetFetchOptions()
        options.sizeOption = .specify(pickerConfig.maximumPreviewSize)
        options.imageDeliveryMode = .highQualityFormat
        
        activityIndicator.startAnimating()
        
        assetRequest = AssetFetchTool.requestPhoto(for: model.asset, options: options) { [weak self] result, _ in
            if case .success(let response) = result {
                self?.assetImageView.image = response.photo
            }
            self?.requestLivePhoto(model, pickerConfig: pickerConfig)
        }
    }
    
    private func requestLivePhoto(_ model: AssetModel, pickerConfig: PickerConfig) {
        let options = AssetFetchOptions()
        options.sizeOption = .specify(pickerConfig.maximumPreviewSize)
        options.imageDeliveryMode = .highQualityFormat
        
        assetRequest = AssetFetchTool.requestLivePhoto(for: model.asset, options: options, completion: { [weak self] result, _ in
            self?.activityIndicator.stopAnimating()
            if case .success(let response) = result {
                self?.livePhotoView.livePhoto = response.livePhoto
            }
        })
    }
    
    @objc private func livePhotoLongPress(_ gesture: UILongPressGestureRecognizer) {
        if livePhotoView.livePhoto == nil { return }
        switch gesture.state {
        case .began:
            livePhotoView.startPlayback(with: .full)
        case .ended, .cancelled:
            livePhotoView.stopPlayback()
        default:
            break
        }
    }
    
    override func handleSingleTapGesture() {
        super.handleSingleTapGesture()
        isShowToolBar.toggle()
    }
    
    override func beginPanGesture() {
        super.beginPanGesture()
        livePhotoTipView.isHidden = true
    }
    
    override func finishPanGesture(dismiss: Bool) {
        super.finishPanGesture(dismiss: dismiss)
        if !dismiss {
            livePhotoTipView.isHidden = !isShowToolBar
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        livePhotoView.frame = assetImageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        livePhotoView.livePhoto = nil
    }
    
}

extension AssetPreviewLivePhotoCell: PHLivePhotoViewDelegate {
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.isHidden = false
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.isHidden = true
    }
    
}

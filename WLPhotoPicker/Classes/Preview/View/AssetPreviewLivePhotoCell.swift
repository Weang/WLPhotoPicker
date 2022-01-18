//
//  AssetPreviewLivePhotoCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit
import PhotosUI

public class AssetPreviewLivePhotoCell: AssetPreviewCell {

    private let livePhotoTipView = AssetPreviewLivePhotoView()
    private let livePhotoView = PHLivePhotoView()
    
    override var isShowToolBar: Bool {
        didSet {
            livePhotoTipView.isHidden = !isShowToolBar
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        livePhotoView.isHidden = true
        livePhotoView.playbackGestureRecognizer.isEnabled = false
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.delegate = self
        assetImageView.addSubview(livePhotoView)
        
        contentScrollView.bringSubviewToFront(assetImageView)
        
        contentView.addSubview(livePhotoTipView)
        livePhotoTipView.snp.makeConstraints { make in
            make.left.equalTo(iCloudView.snp.left)
            make.top.equalTo(iCloudView.snp.top)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.minimumPressDuration = 0.3
        contentScrollView.addGestureRecognizer(longPressGesture)
    }
    
    override func setProgress(_ progress: Double) {
        super.setProgress(progress)
        livePhotoTipView.isHidden = progress != 1 || !isShowToolBar
    }
    
    override func requestOtherAssetData(_ model: AssetModel) {
        let options = AssetFetchOptions()
        options.sizeOption = .original
        options.imageDeliveryMode = .highQualityFormat
        options.progressHandler = defaultProgressHandle
        
        assetRequest = AssetFetchTool.requestLivePhoto(for: model.asset, options: options, completion: { [weak self] result, _ in
            self?.setProgress(1)
            if case .success(let res) = result {
                self?.livePhotoView.livePhoto = res.livePhoto
            } else {
                self?.livePhotoView.livePhoto = nil
            }
        })
    }
    
    override func handleSingleTapGes() {
        super.handleSingleTapGes()
        isShowToolBar.toggle()
    }
    
    override func beginPanGes() {
        super.beginPanGes()
        livePhotoTipView.isHidden = true
    }
    
    override func finishPanGes(dismiss: Bool) {
        super.finishPanGes(dismiss: dismiss)
        if !dismiss {
            livePhotoTipView.isHidden = !isShowToolBar
        }
    }
    
    @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        livePhotoView.frame = assetImageView.bounds
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        livePhotoView.livePhoto = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AssetPreviewLivePhotoCell: PHLivePhotoViewDelegate {
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.isHidden = false
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.isHidden = true
    }
    
}

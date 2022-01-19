//
//  AssetPreviewVideoCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/27.
//

import UIKit
import AVKit

class AssetPreviewVideoCell: AssetPreviewCell {
    
    let iCloudView = AssetPreviewICloudView()
    let playButton = UIButton()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var isVideoFinishLoading: Bool = false
    var isPlaying: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        doubleTapGesture.isEnabled = false
        
        playButton.backgroundColor = .clear
        playButton.setBackgroundImage(BundleHelper.imageNamed("video_play"), for: .normal)
        playButton.isUserInteractionEnabled = false
        playButton.tintColor = .white
        contentView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.center.equalToSuperview()
        }
        
        iCloudView.isHidden = true
        contentView.addSubview(iCloudView)
        iCloudView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(keyWindowSafeAreaInsets.top + 52)
        }
        
        activityIndicator.removeFromSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func cellDidScroll() {
        super.cellDidScroll()
        setPlayingStatus(isPlaying: false, changeToolbar: false)
    }
    
    func setICloudProgress(_ progress: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.iCloudView.isHidden = progress == 1
            self?.iCloudView.progress = progress
        }
    }
    
    override func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        super.setAsset(model, thumbnail: thumbnail, pickerConfig: pickerConfig)
        
        contentScrollView.minimumZoomScale = 1
        contentScrollView.maximumZoomScale = 1
        
        resetPlayer()
    }
    
    func requestVideo() {
        guard let model = self.model else {
            return
        }
        
        let options = AssetFetchOptions()
        options.videoDeliveryMode = .highQualityFormat
        options.progressHandler = setICloudProgress
        
        assetRequest = AssetFetchTool.requestAVAsset(for: model.asset, options: options) { [weak self] result, _ in
            self?.setICloudProgress(1)
            if case .success(let response) = result {
                self?.isVideoFinishLoading = true
                self?.setupPlayer(playerItem: response.playerItem)
            }
        }
    }
    
    func setupPlayer(playerItem: AVPlayerItem) {
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = assetImageView.layer.bounds
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.isHidden = true
        assetImageView.layer.addSublayer(playerLayer!)
        if isPlaying {
            setPlayingStatus(isPlaying: true, changeToolbar: false)
        }
    }
    
    @objc func playerItemDidPlayToEndTime() {
        player?.seek(to: .zero)
        player?.pause()
        playerLayer?.isHidden = true
        setPlayingStatus(isPlaying: false, changeToolbar: true)
    }
    
    func setPlayingStatus(isPlaying: Bool, changeToolbar: Bool) {
        self.isPlaying = isPlaying
        playButton.isHidden = isPlaying
        if isPlaying {
            if isVideoFinishLoading {
                player?.play()
                playerLayer?.isHidden = false
            } else {
                requestVideo()
            }
        } else {
            player?.pause()
        }
        if changeToolbar {
            delegate?.previewCellSingleTap(self, shouldShowToolbar: !isPlaying)
        }
    }
    
    override func handleSingleTapGesture() {
        setPlayingStatus(isPlaying: !isPlaying, changeToolbar: true)
    }
    
    override func beginPanGesture() {
        super.beginPanGesture()
        setPlayingStatus(isPlaying: false, changeToolbar: false)
        playButton.isHidden = true
        iCloudView.alpha = 0
    }
    
    override func finishPanGesture(dismiss: Bool) {
        super.finishPanGesture(dismiss: dismiss)
        if !dismiss {
            setPlayingStatus(isPlaying: false, changeToolbar: false)
            iCloudView.alpha = 1
        }
    }
    
    func resetPlayer() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        isVideoFinishLoading = false
        iCloudView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

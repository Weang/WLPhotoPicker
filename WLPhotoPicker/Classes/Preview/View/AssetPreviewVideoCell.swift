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
    var isVideoFetching: Bool = false
    var isPlaying: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func setupView() {
        super.setupView()
        
        activityIndicator.removeFromSuperview()
        
        playButton.backgroundColor = .clear
        playButton.setBackgroundImage(BundleHelper.imageNamed("video_play"), for: .normal)
        playButton.isUserInteractionEnabled = false
        playButton.tintColor = .white
        contentScrollView.addSubview(playButton)
        
        iCloudView.isHidden = true
        contentView.addSubview(iCloudView)
        iCloudView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(keyWindowSafeAreaInsets.top + 52)
        }
    }
    
    override func setupGesture() {
        super.setupGesture()
        
        doubleTapGesture.isEnabled = false
    }
    
    override func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        super.setAsset(model, thumbnail: thumbnail, pickerConfig: pickerConfig)
        
        resetPlayer()
    }
    
    override func layoutImage(_ image: UIImage?) {
        super.layoutImage(image)
        
        contentScrollView.minimumZoomScale = 1
        contentScrollView.maximumZoomScale = 1
    }
    
    func cellDidScroll() {
        setPlayingStatus(isPlaying: false, changeToolbar: false)
    }
    
    func setICloudProgress(_ progress: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.iCloudView.isHidden = progress == 1
            self?.iCloudView.progress = progress
        }
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
            delegate?.previewCell(self, shouldShowToolbar: !isPlaying)
        }
    }
    
    func requestVideo() {
        guard let model = self.model, !isVideoFetching else {
            return
        }
        isVideoFetching = true
        
        let options = AssetFetchOptions()
        options.videoDeliveryMode = .highQualityFormat
        options.progressHandler = setICloudProgress
        
        assetRequest = AssetFetchTool.requestAVAsset(for: model.asset, options: options) { [weak self] result, _ in
            self?.setICloudProgress(1)
            guard case .success(let response) = result else { return }
            self?.isVideoFinishLoading = true
            self?.isVideoFetching = false
            self?.setupPlayer(playerItem: response.playerItem)
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
        isVideoFetching = false
        iCloudView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playButton.frame = CGRect(x: (contentScrollView.width - 60) * 0.5,
                                  y: (contentScrollView.height - 60) * 0.5,
                                  width: 60,
                                  height: 60)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPlayer()
    }
    
    deinit {
        resetPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

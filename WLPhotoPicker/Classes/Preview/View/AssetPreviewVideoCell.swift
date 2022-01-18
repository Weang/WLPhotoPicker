//
//  AssetPreviewVideoCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/27.
//

import UIKit
import AVKit

class AssetPreviewVideoCell: AssetPreviewCell {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    let playButton = UIButton()
    
    var isPlaying: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        doubleTapGesture.isEnabled = false
        
        playButton.backgroundColor = .clear
        playButton.setBackgroundImage(BundleHelper.imageNamed("video_play"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonClick), for: .touchUpInside)
        playButton.tintColor = .white
        contentView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.center.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func cellDidScroll() {
        super.cellDidScroll()
        setPlayingStatus(false, changeToolbar: false)
    }
    
    override func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        super.setAsset(model, thumbnail: thumbnail, pickerConfig: pickerConfig)
        
        contentScrollView.minimumZoomScale = 1
        contentScrollView.maximumZoomScale = 1
        
        resetPlayer()
    }
    
    override func requestOtherAssetData(_ model: AssetModel) {
        let options = AssetFetchOptions()
        options.progressHandler = defaultProgressHandle
        options.videoDeliveryMode = .mediumQualityFormat
        setProgress(0)
        assetRequest = AssetFetchTool.requestAVAsset(for: model.asset, options: options) { [weak self] result, _ in
            self?.setProgress(1)
            if case .success(let response) = result {
                self?.setupPlayer(playerItem: response.playerItem)
            }
        }
    }
    
    func setupPlayer(playerItem: AVPlayerItem) {
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.isHidden = true
        assetImageView.layer.addSublayer(playerLayer!)
        layoutSubviews()
        if isPlaying {
            setPlayingStatus(true, changeToolbar: true)
        }
    }
    
    func resetPlayer() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    @objc func playerItemDidPlayToEndTime() {
        player?.seek(to: .zero)
        player?.pause()
        playerLayer?.isHidden = true
        setPlayingStatus(false, changeToolbar: true)
    }
    
    func setPlayingStatus(_ isPlaying: Bool, changeToolbar: Bool = true) {
        self.isPlaying = isPlaying
        playButton.isHidden = isPlaying
        if isPlaying {
            player?.play()
            playerLayer?.isHidden = false
        } else {
            player?.pause()
        }
        if changeToolbar {
            delegate?.previewCellSingleTap(self, shouldShowToolbar: !isPlaying)
        }
    }
    
    @objc func playButtonClick() {
        setPlayingStatus(true)
    }
    
    override func handleSingleTapGes() {
        setPlayingStatus(!self.isPlaying)
    }
    
    override func beginPanGes() {
        super.beginPanGes()
        setPlayingStatus(false, changeToolbar: false)
        playButton.isHidden = true
    }
    
    override func finishPanGes(dismiss: Bool) {
        super.finishPanGes(dismiss: dismiss)
        if !dismiss {
            setPlayingStatus(false, changeToolbar: false)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPlayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = assetImageView.layer.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

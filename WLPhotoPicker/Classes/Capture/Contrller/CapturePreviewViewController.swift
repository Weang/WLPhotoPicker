//
//  CapturePreviewViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/2.
//

import UIKit
import AVFoundation

protocol CapturePreviewViewControllerDelegate: AnyObject {
    func previewViewController(_ controller: CapturePreviewViewController, didClickDoneButtonWithPhoto photo: UIImage)
    func previewViewController(_ controller: CapturePreviewViewController, didClickDoneButtonWithVideoUrl url: URL)
}

class CapturePreviewViewController: UIViewController {
    
    weak var delegate: CapturePreviewViewControllerDelegate?
    
    private let toolBar = CapturePreviewToolBar()
    
    private let previewPhoto: UIImage?
    private let videoUrl: URL?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    init(previewPhoto: UIImage? = nil, videoUrl: URL? = nil) {
        self.previewPhoto = previewPhoto
        self.videoUrl = videoUrl
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if previewPhoto != nil {
            setupImageView()
        } else if videoUrl != nil {
            setupVideoPlayer()
        }
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        
        toolBar.delegate = self
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func setupImageView() {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.image = previewPhoto
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupVideoPlayer() {
        guard let videoUrl = videoUrl else {
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        let player = AVPlayer(playerItem: AVPlayerItem(asset: AVURLAsset(url: videoUrl)))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.frame = view.layer.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        player.play()
        self.playerLayer = playerLayer
        self.player = player
    }
    
    @objc private func playToEndTime() {
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

extension CapturePreviewViewController: CapturePreviewToolBarDelegate {
    
    func toolBarDidClickCancelButton(_ toolBar: CapturePreviewToolBar) {
        dismiss(animated: false, completion: nil)
    }
    
    func toolBarDidClickDoneButton(_ toolBar: CapturePreviewToolBar) {
        if let previewPhoto = self.previewPhoto {
            delegate?.previewViewController(self, didClickDoneButtonWithPhoto: previewPhoto)
        } else if let videoUrl = self.videoUrl {
            delegate?.previewViewController(self, didClickDoneButtonWithVideoUrl: videoUrl)
        }
    }
    
}

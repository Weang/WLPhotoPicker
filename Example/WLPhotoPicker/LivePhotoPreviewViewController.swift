//
//  LivePhotoPreviewViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/21.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import PhotosUI
import AVKit

class LivePhotoPreviewViewController: UIViewController {

    let livePhotoView = PHLivePhotoView()
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        livePhotoView.contentMode = .scaleAspectFit
        view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let previewVideoButton = UIButton()
        previewVideoButton.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.6784313725, blue: 0.1019607843, alpha: 1)
        previewVideoButton.setTitleColor(.white, for: .normal)
        previewVideoButton.setTitle("预览视频", for: .normal)
        previewVideoButton.layer.cornerRadius = 6
        previewVideoButton.layer.masksToBounds = true
        previewVideoButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        previewVideoButton.addTarget(self, action: #selector(previewVideo), for: .touchUpInside)
        view.addSubview(previewVideoButton)
        previewVideoButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.right.equalTo(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.bottom).offset(-20)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        livePhotoView.startPlayback(with: .full)
    }

    @objc func previewVideo() {
        guard let videoURL = self.videoURL else {
            return
        }
        livePhotoView.stopPlayback()
        let playerItem = AVPlayerItem(asset: AVAsset(url: videoURL))
        let player = AVPlayer(playerItem: playerItem)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            player.play()
        }
    }
    
}

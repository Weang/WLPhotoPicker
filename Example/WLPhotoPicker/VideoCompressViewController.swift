//
//  VideoCompressViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/1/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import AVKit
import SVProgressHUD

class VideoCompressViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let tipLabel = UILabel()
        tipLabel.numberOfLines = 0
        tipLabel.font = UIFont.systemFont(ofSize: 15)
        tipLabel.textColor = .darkGray
        tipLabel.text = "把视频文件拖到项目中，修改 VideoCompressViewController 中的文件名，再点击“开始压缩”按钮"
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        let button = UIButton()
        button.setTitle("开始压缩", for: .normal)
        button.addTarget(self, action: #selector(beginCompress), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipLabel.snp.bottom).offset(30)
        }
        
    }
    
    @objc func beginCompress() {
        guard let videoPath = Bundle.main.path(forResource: "video", ofType: "mov") else {
            return
        }
        
        let outputPath = NSTemporaryDirectory() + "video.mp4"
        if FileManager.default.fileExists(atPath: outputPath) {
            try? FileManager.default.removeItem(atPath: outputPath)
        }
        
        let manager = VideoCompressManager(avAsset: AVAsset(url: URL(fileURLWithPath: videoPath)), outputPath: outputPath)
        manager.compressSize = ._960x540
        manager.frameDuration = 24
        manager.videoExportFileType = .mp4
        if !(TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
            // 模拟器调用添加水印方法会崩溃，有没有大佬知道解决办法
            // https://developer.apple.com/library/archive/samplecode/AVSimpleEditoriOS/Introduction/Intro.html#//apple_ref/doc/uid/DTS40012797
            // 官方demo也会崩溃 = =、
            manager.addWaterMark(image: UIImage.init(named: "bilibili")) { size in
                return CGRect(x: size.width * 0.75, y: size.width * 0.05, width: size.width * 0.2, height: size.width * 0.1)
            }
        }
        manager.exportVideo { progress in
            SVProgressHUD.showProgress(Float(progress))
        } completion: { outputURL in
            if let _ = manager.error {
                SVProgressHUD.showError(withStatus: "压缩失败")
            } else {
                SVProgressHUD.showSuccess(withStatus: "压缩成功")
                print(outputURL)
                let playerItem = AVPlayerItem(asset: AVAsset(url: outputURL))
                let player = AVPlayer(playerItem: playerItem)
                let controller = AVPlayerViewController()
                controller.player = player
                self.present(controller, animated: true) {
                    player.play()
                }
            }
        }

    }
    
}

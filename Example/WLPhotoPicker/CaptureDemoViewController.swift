//
//  CaptureDemoViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import AVFoundation
import AVKit
import SVProgressHUD

class CaptureDemoViewController: UIViewController {
    
    let switchView = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "是否添加水印"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(120)
        }
        
        view.addSubview(switchView)
        switchView.snp.makeConstraints { make in
            make.centerY.equalTo(label.snp.centerY)
            make.right.equalTo(-20)
        }
        
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(openCapture), for: .touchUpInside)
        button.setTitle("打开自定义相机", for: .normal)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc func openCapture() {
        let vc = CaptureViewController(captureConfig: CaptureConfig(), photoEditConfig: PhotoEditConfig())
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func showPlayer(_ url: URL) {
        let playerItem = AVPlayerItem(asset: AVAsset(url: url))
        let player = AVPlayer(playerItem: playerItem)
        let controller = AVPlayerViewController()
        controller.player = player
        player.play()
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension CaptureDemoViewController: CaptureViewControllerDelegate {
    
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL) {
        if !switchView.isOn {
            self.showPlayer(videoUrl)
        } else {
            SVProgressHUD.show()
            DispatchQueue.global().async {
                let path = NSTemporaryDirectory() + "video.mp4"
                if FileManager.default.fileExists(atPath: path) {
                    try? FileManager.default.removeItem(atPath: path)
                }
                let manager = VideoCompressManager(avAsset: AVAsset(url: videoUrl), outputPath: path)
                manager.compressVideo = false
                manager.addWaterMark(image: UIImage.init(named: "bilibili")) { size in
                    return CGRect(x: size.width * 0.75, y: size.height * 0.05, width: size.width * 0.2, height: size.width * 0.1)
                }
                manager.exportVideo { videoUrl in
                    SVProgressHUD.dismiss()
                    self.showPlayer(videoUrl)
                }
            }
        }
    }
    
}

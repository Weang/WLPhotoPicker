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
import Eureka

class CaptureDemoViewController: FormViewController {
    
    var addWaterMark: Bool = false
    let captureConfig = CaptureConfig()
    var photoEditConfig: PhotoEditConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Capture", style: .done, target: self, action: #selector(openCapture))
        
        form
        
        +++ Section("拍照")
        <<< SwitchRow() { row in
            row.title = "是否允许拍摄照片"
            row.value = self.captureConfig.allowTakingPhoto
        }.onChange { row in
            self.captureConfig.allowTakingPhoto = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否允许拍摄视频"
            row.value = self.captureConfig.allowTakingVideo
        }.onChange { row in
            self.captureConfig.allowTakingVideo = (row.value ?? false)
        }
        
        <<< IntRow() { row in
            row.title = "可选择的最长视频时长"
            row.value = 20
        }.onChange({ row in
            self.captureConfig.captureMaximumVideoDuration = TimeInterval(row.value ?? 20)
        })
        
        <<< IntRow() { row in
            row.title = "拍摄视频帧率"
            row.value = 60
        }.onChange({ row in
            self.captureConfig.captureVideoFrameRate = TimeInterval(row.value ?? 20)
        })
        
        <<< PickerInputRow<String>() { row in
            row.title = "闪光灯模式"
            row.options = ["auto", "on", "off"]
            row.value = "off"
        }.onChange({ row in
            let value: CaptureFlashMode
            switch (row.value ?? "off") {
            case "auto": value = .auto
            case "on": value = .on
            case "off": value = .off
            default : value = .off
            }
            self.captureConfig.captureFlashMode = value
        })
        
        <<< PickerInputRow<String>() { row in
            row.title = "拍摄视频尺寸"
            row.options = ["cif352x288", "vga640x480", "hd1280x720", "hd1920x1080", "hd4K3840x2160"]
            row.value = "hd4K3840x2160"
        }.onChange({ row in
            let value: CaptureSessionPreset
            switch (row.value ?? "hd4K3840x2160") {
            case "cif352x288": value = .cif352x288
            case "vga640x480": value = .vga640x480
            case "hd1280x720": value = .hd1280x720
            case "hd1920x1080": value = .hd1920x1080
            case "hd4K3840x2160": value = .hd4K3840x2160
            default : value = .hd4K3840x2160
            }
            self.captureConfig.captureSessionPreset = value
        })
        
        <<< PickerInputRow<String>() { row in
            row.title = "视频防抖模式"
            row.options = ["auto", "off", "standard", "cinematic", "cinematicExtended iOS 13.0"]
            row.value = "auto"
        }.onChange({ row in
            let value: CaptureVideoStabilizationMode
            switch (row.value ?? "auto") {
            case "auto": value = .auto
            case "off": value = .off
            case "standard": value = .standard
            case "cinematic": value = .cinematic
            case "cinematicExtended iOS 13.0":
                if #available(iOS 13.0, *) {
                    value = .cinematicExtended
                } else {
                    value = .auto
                }
            default : value = .auto
            }
            self.captureConfig.captureVideoStabilizationMode = value
        })
        
        +++ Section("编辑")
        <<< SwitchRow() { row in
            row.title = "拍摄照片后是否可编辑"
            row.value = self.photoEditConfig != nil
        }.onChange { row in
            self.photoEditConfig = (row.value ?? false) ? PhotoEditConfig() : nil
        }
        
        +++ Section("导出")
        <<< SwitchRow() { row in
            row.title = "是否添加水印"
            row.value = self.addWaterMark
        }.onChange { row in
            self.addWaterMark = (row.value ?? false)
        }
        
    }
    
    @objc func openCapture() {
        let vc = CaptureViewController(captureConfig: captureConfig, photoEditConfig: photoEditConfig )
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func showPlayer(_ url: URL) {
        let playerItem = AVPlayerItem(asset: AVAsset(url: url))
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(playerItem: playerItem)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true) {
            controller.player?.play()
        }
    }
    
}

extension CaptureDemoViewController: CaptureViewControllerDelegate {
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingPhoto photo: UIImage) {
        viewController.presentingViewController?.dismiss(animated: true, completion: {
            let vc = PhotoPreviewViewController()
            vc.imageView.image = photo
            self.present(vc, animated: true)
        })
    }
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL) {
        if !addWaterMark {
            viewController.presentingViewController?.dismiss(animated: true, completion: {
                self.showPlayer(videoUrl)
            })
        } else {
            viewController.presentingViewController?.dismiss(animated: true, completion: nil)
            SVProgressHUD.show()
            DispatchQueue.global().async {
                let outputPath = NSTemporaryDirectory() + "video.mp4"
                if FileManager.default.fileExists(atPath: outputPath) {
                    try? FileManager.default.removeItem(atPath: outputPath)
                }
                let manager = VideoCompressManager(avAsset: AVAsset(url: videoUrl), outputPath: outputPath)
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

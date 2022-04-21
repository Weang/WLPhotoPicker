//
//  SelectVideoViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import Eureka

class SelectVideoViewController: FormViewController {
    
    let config = WLPhotoConfig()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Picker", style: .done, target: self, action: #selector(openPicker))

        // 文件导出路径 tmp/WLPhotoPicker/Picker
        config.pickerConfig.selectableType = [.video]
        config.pickerConfig.exportVideoURLWhenPick = true
        config.pickerConfig.videoExportFileType = .mov
        
        form
        +++ Section("如果需要导出视频，配置中的'导出视频地址'选项必须开启，否则压缩参数会失效")
        <<< SwitchRow() { row in
            row.title = "是否导出视频地址"
            row.value = self.config.pickerConfig.exportVideoURLWhenPick
        }.cellUpdate({ cell, row in
            cell.switchControl.isEnabled = false
        })
        
        +++ Section("""
        如果在选择视频时勾选原图，导出地址存在两种情况：
        1- 如果在相册中存在视频文件，将直接返回视频源文件地址
        2- 如果视频在本地不存在，请求AVAsset成功之后使用视频原来的帧率、尺寸和比特率导出视频
        """)
        <<< SwitchRow() { row in
            row.title = "是否可以选择原视频"
            row.value = self.config.pickerConfig.allowVideoSelectOriginal
        }.onChange { row in
            self.config.pickerConfig.allowVideoSelectOriginal = (row.value ?? false)
        }
        
        +++ Section("Picker")
        <<< PickerInputRow<String>() { row in
            row.title = "导出视频尺寸"
            row.options = ["_640x480", "_960x540", "_1280x720", "_1920x1080", "_3840x2160"]
            row.value = "_960x540"
        }.onChange({ row in
            let value: PickerVideoCompressSize
            switch (row.value ?? "_960x540") {
            case "_640x480": value = ._640x480
            case "_960x540": value = ._960x540
            case "_1280x720": value = ._1280x720
            case "_1920x1080": value = ._1920x1080
            case "_3840x2160": value = ._3840x2160
            default : value = ._960x540
            }
            self.config.pickerConfig.videoExportCompressSize = value
        })

        <<< IntRow() { row in
            row.title = "导出视频帧率"
            row.value = 30
        }.onChange({ row in
            self.config.pickerConfig.videoExportFrameDuration = Float(row.value ?? 0)
        })

    }
    
    @objc func openPicker() {
        let vc = WLPhotoPickerController(config: config)
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension SelectVideoViewController: WLPhotoPickerControllerDelegate {

    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult]) {
        let vc = PickerResultViewController()
        vc.results = results
        navigationController?.pushViewController(vc, animated: true)
        results.forEach { result in
            switch result.result {
            case .video(let result):
                if let videoURL = result.videoURL {
                    print(videoURL)
                }
            default:
                break
            }
        }
    }

}

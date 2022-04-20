//
//  LivePhotoToVideoViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import SVProgressHUD
import Eureka

class LivePhotoToVideoViewController: FormViewController {
    
    var isMute: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Picker", style: .done, target: self, action: #selector(openPicker))
        
        form +++ Section("")
        <<< SwitchRow() { row in
            row.title = "是否静音"
            row.value = self.isMute
        }.onChange { row in
            self.isMute = row.value ?? false
        }
    }
    
    @objc func openPicker() {
        let config = WLPhotoConfig()
        config.pickerConfig.selectableType = [.video]
        config.pickerConfig.allowVideoSelectOriginal = true
        config.pickerConfig.allowsMultipleSelection = false
        config.pickerConfig.exportVideoURLWhenPick = true
        let vc = WLPhotoPickerController(config: config)
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension LivePhotoToVideoViewController: WLPhotoPickerControllerDelegate {
    
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult]) {
        guard let result = results.first,
              case .video(let videoResult) = result.result,
              let videoURL = videoResult.videoURL else {
            return
        }
        
        LivePhotoGenerator.createLivePhotoFrom(videoURL, isMute: isMute) { progress in
            SVProgressHUD.showProgress(Float(progress))
        } completion: { result in
            guard let result = result else {
                return
            }
            SVProgressHUD.dismiss()
            let vc = LivePhotoViewController(result: result)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) {
        pickerController.dismiss(animated: true, completion: nil)
    }
    
}

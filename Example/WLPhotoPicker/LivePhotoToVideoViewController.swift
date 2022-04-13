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

class LivePhotoToVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        view.backgroundColor = .white
        
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
        button.setTitle("选择视频", for: .normal)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc func openPicker() {
        let config = WLPhotoConfig()
        config.pickerConfig.selectableType = [.video]
        config.pickerConfig.allowVideoSelectOriginal = true
        config.pickerConfig.allowSelectMultiPhoto = false
        config.pickerConfig.exportVideoURLWhenPick = true
        let vc = WLPhotoPickerController(config: config)
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }

}

extension LivePhotoToVideoViewController: WLPhotoPickerControllerDelegate {
    
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [AssetPickerResult]) {
        guard let result = results.first,
              case .video(let videoResult) = result.result,
        let videoURL = videoResult.videoURL else {
            return
        }
        SVProgressHUD.show()
        LivePhotoGenerator.createLivePhotoFrom(videoURL) { livePhoto, imageURL, videoURL in
            guard let livePhoto = livePhoto else {
                return
            }
            SVProgressHUD.dismiss()
            let vc = LivePhotoViewController(livePhoto: livePhoto, imageURL: imageURL, videoURL: videoURL)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) {
        pickerController.dismiss(animated: true, completion: nil)
    }
    
    func pickerController(_ pickerController: WLPhotoPickerController, didOccurredError error: WLPhotoError) {
        let alert = UIAlertController.init(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "确定", style: .cancel, handler: { _ in
            
        }))
        pickerController.present(alert, animated: true, completion: nil)
    }
}

//
//  AvatarViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Eureka
import WLPhotoPicker

class AvatarViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WLPhotoConfig()
        config.pickerConfig.allowsMultipleSelection = false
        config.pickerConfig.dismissPickerAfterDone = false
        config.pickerConfig.selectableType = [.photo]
        config.pickerConfig.allowPreview = false
        
        // 如果底部toolbar的所有按钮都隐藏的话，toolbar也会隐藏
        config.pickerConfig.allowSelectOriginal = false
        config.pickerConfig.showPickerDoneButton = false
        
        form +++ Section("Avatar")
        
        <<< LabelRow() { row in
            row.title = "选择头像"
        }.cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            let vc = WLPhotoPickerController(config: config)
            vc.pickerDelegate = self
            self.present(vc, animated: true)
        }
    }
    
}

extension AvatarViewController: WLPhotoPickerControllerDelegate {
    
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) {
        pickerController.dismiss(animated: true)
    }
    
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult]) {
        guard let photo = results.first?.photo else {
            return
        }
        
        let vc = PhotoEditCropViewController(photo: photo, photoEditCropRatios: .ratio_1_1)
        vc.delegate = self
        pickerController.pushViewController(vc, animated: true)
    }
    
}

extension AvatarViewController: PhotoEditCropViewControllerDelegate {
    
    func cropViewControllerDidClickCancel(_ viewController: PhotoEditCropViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    func cropViewController(_ viewController: PhotoEditCropViewController, didFinishCrop image: UIImage, cropRect: PhotoEditCropRect, orientation: UIImage.Orientation) {
        print(cropRect)
        print(orientation)
        viewController.dismiss(animated: true)
        let vc = AvatarResultViewController()
        vc.imageView.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

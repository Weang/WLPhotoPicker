//
//  ViewController.swift
//  WLPhotoPicker
//
//  Created by Weang on 01/18/2022.
//  Copyright (c) 2022 Weang. All rights reserved.
//

import UIKit
import Eureka

class ViewController: FormViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let config = WLPhotoConfig()
//        config.pickerConfig.selectableType = [.video, .GIF, .photo]
//        config.pickerConfig.saveImageToLocalWhenPick = true
//        config.pickerConfig.saveVideoToLocalWhenPick = true
//        config.photoEditConfig.photoEditPasters = (1...18).map { "paster\($0)" }.map{ PhotoEditPasterProvider.imageName($0) }
//        if #available(iOS 13.0, *) {
//            config.captureConfig.captureVideoStabilizationMode = .cinematicExtended
//        }
//        let vc = WLPhotoPickerController(config: config)
//        vc.pickerDelegate = self
//        self.present(vc, animated: true, completion: nil)
//
        self.navigationItem.title = "WLPhotoPicker"
        
        form +++ Section()
        
        <<< LabelRow() { row in
            row.title = "选择图片"
        }.cellSetup({ cell, row in
            cell.accessoryType = .disclosureIndicator
        }).onCellSelection({ cell, row in
            self.navigationController?.pushViewController(PickerViewController(), animated: true)
        })
        
        <<< LabelRow() { row in
            row.title = "视频压缩"
        }.cellSetup({ cell, row in
            cell.accessoryType = .disclosureIndicator
        })
        
    }
    
}

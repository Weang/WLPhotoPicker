//
//  ViewController.swift
//  WLPhotoPicker
//
//  Created by Weang on 01/18/2022.
//  Copyright (c) 2022 Weang. All rights reserved.
//

import UIKit
import Eureka
import WLPhotoPicker

class ViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "WLPhotoPicker"
        
        form
        
        +++ Section("Picker")
        <<< LabelRow() { row in
            row.title = "选择图片"
        }.cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            self.navigationController?.pushViewController(PickerViewController(), animated: true)
        }
        
        
        +++ Section("Capture")
        <<< LabelRow() { row in
            row.title = "自定义相机"
        }.cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { _, _ in
            self.navigationController?.pushViewController(CaptureDemoViewController(), animated: true)
        }
        
        +++ Section("Live Photo")
        <<< LabelRow() { row in
            row.title = "视频转实况"
        }.cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { _, _ in
            self.navigationController?.pushViewController(LivePhotoToVideoViewController(), animated: true)
        }
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let config = WLPhotoConfig()
//        config.photoEditConfig.photoEditPasters = (1...18).map{ "paster\($0)" }.map{ PhotoEditPasterProvider.imageName($0) }
//        let vc = WLPhotoPickerController(config: config)
//        self.present(vc, animated: true, completion: nil)
//    }
}

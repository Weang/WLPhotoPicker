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
        
        let b = UIView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        b.backgroundColor = .red
        view.addSubview(b)
        
        let a = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        a.image = UIImage.init(named: "IMG_7741")
 
        a.transform = CGAffineTransform(rotationAngle: Double.pi)
            .scaledBy(x: 2, y: 2)
            .translatedBy(x: 50, y: 50)
//        a.transform = CGAffineTransform(scaleX: 2, y: 2)
//            .translatedBy(x: 50, y: 50)
        a.backgroundColor = .black
        b.addSubview(a)
        b.layer.masksToBounds = true

//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            b.transform = CGAffineTransform(scaleX: 4, y: 4)
//                .translatedBy(x: Double(300) / 4, y: Double(300) / 4)
//            print(b.frame)
//        }
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
        }.cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { cell, row in
            self.navigationController?.pushViewController(PickerViewController(), animated: true)
        }

        <<< LabelRow() { row in
            row.title = "视频压缩"
        }.cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
        }
        
    }
    
}

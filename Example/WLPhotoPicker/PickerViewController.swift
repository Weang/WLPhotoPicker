//
//  PickerViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/1/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import Eureka

class PickerViewController: FormViewController {
    
    let config = WLPhotoConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Picker"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Picker", style: .done, target: self, action: #selector(openPicker))
        
        form +++ Section("Picker")
        
        <<< PickerInputRow<String>() { row in
            row.title = "一行的个数"
            row.options = ["3", "4", "5"]
            row.value = "4"
        }.onChange({ row in
            self.config.pickerConfig.columnsOfPhotos = Int(row.value ?? "4") ?? 4
        })
        
        <<< SwitchRow() { row in
            row.title = "是否可以多选照片"
            row.value = self.config.pickerConfig.allowSelectMultiPhoto
        }.onChange { row in
            self.config.pickerConfig.allowSelectMultiPhoto = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "点击按钮是否进入预览页面"
            row.value = self.config.pickerConfig.allowPreview
        }.onChange { row in
            self.config.pickerConfig.allowPreview = (row.value ?? false)
        }
        
        <<< MultipleSelectorRow<String>() { row in
            row.title = "可选择资源类型"
            row.options = ["照片", "视频", "动图", "实况"]
            row.value = ["照片", "视频", "动图", "实况"]
        }.onChange({ row in
            var type: PickerSelectionType = []
            let value = row.value ?? Set<String>()
            if value.contains("照片") {
                type.insert(.photo)
            }
            if value.contains("视频") {
                type.insert(.video)
            }
            if value.contains("动图") {
                type.insert(.GIF)
            }
            if value.contains("实况") {
                type.insert(.livePhoto)
            }
            self.config.pickerConfig.selectableType = type
        }).onPresent { from, to in
                to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(PickerViewController.multipleSelectorDone(_:)))
            }
        
        <<< PickerInputRow<String>() { row in
            row.title = "排序方式"
            row.options = ["升序", "降序"]
            row.value = "升序"
        }.onChange({ row in
            self.config.pickerConfig.sortType = row.value == "升序" ? .asc : .desc
        })
        
        <<< IntRow() { row in
            row.title = "可选择的最长视频时长"
            row.value = 120
        }.onChange({ row in
            self.config.pickerConfig.pickerMaximumVideoDuration = TimeInterval(row.value ?? 0)
        })
        
        <<< PickerInputRow<String>() { row in
            row.title = "选择个数限制"
            row.options = (1...9).map{ String($0) }
            row.value = "9"
        }.onChange({ row in
            self.config.pickerConfig.selectCountLimit = Int(row.value ?? "9") ?? 9
        })
        
        <<< SwitchRow() { row in
            row.title = "图片是否可编辑"
            row.value = self.config.pickerConfig.allowEditPhoto
        }.onChange { row in
            self.config.pickerConfig.allowEditPhoto = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否显示添加更多照片"
            row.value = self.config.pickerConfig.canAddMoreAssetWhenLimited
        }.onChange { row in
            self.config.pickerConfig.canAddMoreAssetWhenLimited = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否自动选中添加的照片"
            row.value = self.config.pickerConfig.autoSelectAssetFromLimitedLibraryPicker
        }.onChange { row in
            self.config.pickerConfig.autoSelectAssetFromLimitedLibraryPicker = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否可选择原图"
            row.value = self.config.pickerConfig.allowSelectOriginal
        }.onChange { row in
            self.config.pickerConfig.allowSelectOriginal = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "选取照片时是否导出照片地址"
            row.value = self.config.pickerConfig.exportImageURLWhenPick
        }.onChange { row in
            self.config.pickerConfig.exportImageURLWhenPick = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "选取视频时是否导出视频地址"
            row.value = self.config.pickerConfig.exportVideoURLWhenPick
        }.onChange { row in
            self.config.pickerConfig.exportVideoURLWhenPick = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "勾选原图时是否导出原视频"
            row.value = self.config.pickerConfig.allowVideoSelectOriginal
        }.onChange { row in
            self.config.pickerConfig.allowVideoSelectOriginal = (row.value ?? false)
        }
        
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
        
        <<< SwitchRow() { row in
            row.title = "点击确定是否自动关闭"
            row.value = self.config.pickerConfig.dismissPickerAfterDone
        }.onChange { row in
            self.config.pickerConfig.dismissPickerAfterDone = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否保存编辑后的照片"
            row.value = self.config.pickerConfig.saveEditedPhotoToAlbum
        }.onChange { row in
            self.config.pickerConfig.saveEditedPhotoToAlbum = (row.value ?? false)
        }
        
        form +++ Section("Editor")
        
        <<< SwitchRow() { row in
            row.title = "使用自定义贴图"
            row.value = false
        }.onChange { row in
            self.config.photoEditConfig.photoEditPasters = (row.value ?? false) ? (1...18).map{ "paster\($0)" }.map{ PhotoEditPasterProvider.imageName($0) } : []
            if (row.value ?? false),
               !self.config.photoEditConfig.photoEditItemTypes.contains(.paster) {
                self.config.photoEditConfig.photoEditItemTypes.insert(.paster, at: 1)
            }
        }
        
        form +++ Section("Capture")
        
        <<< SwitchRow() { row in
            row.title = "是否使用系统相机进行拍摄"
            row.value = self.config.pickerConfig.useSystemImagePickerController
        }.onChange { row in
            self.config.pickerConfig.useSystemImagePickerController = row.value ?? false
        }
        
        <<< SwitchRow() { row in
            row.title = "是否允许拍摄照片"
            row.value = self.config.pickerConfig.allowTakingPhoto
        }.onChange { row in
            self.config.pickerConfig.allowTakingPhoto = row.value ?? false
        }
        
        <<< SwitchRow() { row in
            row.title = "是否允许拍摄视频"
            row.value = self.config.pickerConfig.allowTakingVideo
        }.onChange { row in
            self.config.pickerConfig.allowTakingVideo = row.value ?? false
        }
        
    }
    
    @objc func multipleSelectorDone(_ item: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func openPicker() {
        let vc = WLPhotoPickerController(config: config)
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension PickerViewController: WLPhotoPickerControllerDelegate {
    
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [AssetPickerResult]) {
        let vc = PickerResultViewController()
        vc.result = results
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

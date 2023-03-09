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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Picker", style: .done, target: self, action: #selector(openPicker))
        
        config.photoEditConfig.photoEditPasters = (1...18).map{ "paster\($0)" }.map{ PhotoEditPasterProvider.imageName($0) }
        
        form +++ Section("Picker")
        
        <<< PickerInputRow<String>() { row in
            row.title = "一行的个数"
            row.options = ["3", "4", "5"]
            row.value = "4"
        }.onChange({ row in
            self.config.pickerConfig.columnsOfPhotos = Int(row.value ?? "4") ?? 4
        })
        
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
            row.value = 0
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
            row.title = "是否显示隐藏相册"
            row.value = self.config.pickerConfig.showHiddenAlbum
        }.onChange { row in
            self.config.pickerConfig.showHiddenAlbum = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否显示最近删除相册"
            row.value = self.config.pickerConfig.showRecentlyDeletedAlbum
        }.onChange { row in
            self.config.pickerConfig.showRecentlyDeletedAlbum = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否可以同时选择图片和视频"
            row.value = self.config.pickerConfig.allowsSelectBothPhotoAndVideo
        }.onChange { row in
            self.config.pickerConfig.allowsSelectBothPhotoAndVideo = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否可以多选照片"
            row.value = self.config.pickerConfig.allowsMultipleSelection
        }.onChange { row in
            self.config.pickerConfig.allowsMultipleSelection = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "点击图片cell是否进入预览页面"
            row.value = self.config.pickerConfig.allowPreview
        }.onChange { row in
            self.config.pickerConfig.allowPreview = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "图片是否可编辑"
            row.value = self.config.pickerConfig.allowEditPhoto
        }.onChange { row in
            self.config.pickerConfig.allowEditPhoto = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否显示添加更多可访问照片"
            row.value = self.config.pickerConfig.canAddMoreAssetWhenLimited
        }.onChange { row in
            self.config.pickerConfig.canAddMoreAssetWhenLimited = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否自动选中添加的可访问照片"
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
            row.title = "选取照片时是否将图片导出文件"
            row.value = self.config.pickerConfig.exportImageURLWhenPick
        }.onChange { row in
            self.config.pickerConfig.exportImageURLWhenPick = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "是否实时更新相册"
            row.value = self.config.pickerConfig.registerPhotoLibraryChangeObserver
        }.onChange { row in
            self.config.pickerConfig.registerPhotoLibraryChangeObserver = (row.value ?? false)
        }
        
        <<< SwitchRow() { row in
            row.title = "点击确定之后是否自动关闭"
            row.value = self.config.pickerConfig.dismissPickerAfterDone
        }.onChange { row in
            self.config.pickerConfig.dismissPickerAfterDone = (row.value ?? false)
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
        
        <<< SwitchRow() { row in
            row.title = "是否使用系统相机进行拍摄"
            row.value = self.config.pickerConfig.useSystemImagePickerController
        }.onChange { row in
            self.config.pickerConfig.useSystemImagePickerController = row.value ?? false
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
    
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult]) {
        if !self.config.pickerConfig.dismissPickerAfterDone {
            pickerController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        let vc = PickerResultViewController()
        vc.results = results
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

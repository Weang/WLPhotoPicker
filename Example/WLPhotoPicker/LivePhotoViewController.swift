//
//  LivePhotoViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import WLPhotoPicker
import SVProgressHUD

class LivePhotoViewController: UIViewController {

    let result: LivePhotoGeneratorRsult
    
    private let livePhotoView = PHLivePhotoView()
    
    init(result: LivePhotoGeneratorRsult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        livePhotoView.livePhoto = result.livePhoto
        livePhotoView.contentMode = .scaleAspectFit
        view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveLivePhoto))
    }
    
    @objc func saveLivePhoto() {
        AssetSaveManager.saveLivePhoto(photoURL: result.imageURL, videoURL: result.videoURL) { _ in
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        } failure: {
            SVProgressHUD.showError(withStatus: "保存失败")
        }
    }

}

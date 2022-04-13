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

    let livePhoto: PHLivePhoto
    let imageURL: URL
    let videoURL: URL
    private let livePhotoView = PHLivePhotoView()
    
    init(livePhoto: PHLivePhoto, imageURL: URL, videoURL: URL) {
        self.livePhoto = livePhoto
        self.imageURL = imageURL
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        livePhotoView.livePhoto = livePhoto
        livePhotoView.contentMode = .scaleAspectFit
        view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveLivePhoto))
    }
    
    @objc func saveLivePhoto() {
        AssetSaveManager.saveLivePhoto(photoURL: imageURL, videoURL: videoURL) { result in
            switch result {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "保存成功")
            case .failure:
                SVProgressHUD.showError(withStatus: "保存失败")
            }
        }
    }

}

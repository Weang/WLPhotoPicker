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

class LivePhotoResultViewController: UIViewController {

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
        view.backgroundColor = .black
        
        livePhotoView.livePhoto = result.livePhoto
        livePhotoView.contentMode = .scaleAspectFit
        view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let saveButton = UIButton()
        saveButton.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.6784313725, blue: 0.1019607843, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("保存到相册", for: .normal)
        saveButton.layer.cornerRadius = 6
        saveButton.layer.masksToBounds = true
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        saveButton.addTarget(self, action: #selector(saveLivePhoto), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.right.equalTo(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.bottom).offset(-20)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        livePhotoView.startPlayback(with: .full)
    }
    
    @objc func saveLivePhoto() {
        AssetSaveManager.saveLivePhoto(photoURL: result.imageURL, videoURL: result.videoURL) { _ in
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        } failure: {
            SVProgressHUD.showError(withStatus: "保存失败")
        }
    }

}

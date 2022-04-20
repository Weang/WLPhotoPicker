//
//  AvatarResultViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class AvatarResultViewController: UIViewController {

    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(view.snp.width).multipliedBy(0.7)
        }
    }
    
}

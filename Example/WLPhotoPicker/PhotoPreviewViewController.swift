//
//  PhotoPreviewViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/21.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class PhotoPreviewViewController: UIViewController {

    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    

}

//
//  NineCollectionViewCell.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class NineCollectionViewCell: UICollectionViewCell {

    let imageView = UIImageView()
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton.setImage(UIImage.init(named: "delete"), for: .normal)
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}

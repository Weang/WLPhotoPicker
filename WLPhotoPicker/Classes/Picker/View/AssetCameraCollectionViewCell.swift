//
//  AssetCameraCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/31.
//

import UIKit

class AssetCameraCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = WLPhotoPickerUIConfig.default.functionItemBackgroundColor
        
        let cameraImageView = UIImageView()
        cameraImageView.image = BundleHelper.imageNamed("camera")?.withRenderingMode(.alwaysTemplate)
        cameraImageView.tintColor = .darkGray
        cameraImageView.contentMode = .scaleAspectFit
        contentView.addSubview(cameraImageView)
        cameraImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(contentView.snp.width).multipliedBy(0.4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

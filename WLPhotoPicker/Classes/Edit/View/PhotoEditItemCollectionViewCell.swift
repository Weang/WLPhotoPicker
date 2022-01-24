//
//  PhotoEditItemCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

class PhotoEditItemCollectionViewCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            iconImageView.tintColor = isSelected ? WLPhotoUIConfig.default.color.primaryColor : .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(24)
        }
    }
    
    func bind(_ type: PhotoEditItemType) {
        iconImageView.image = type.iconImage?.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PhotoEditAdjustCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

class PhotoEditAdjustCollectionViewCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            let selectedColor = WLPhotoUIConfig.default.color.primaryColor
            iconImageView.tintColor = isSelected ? selectedColor : .white
            nameLabel.textColor = isSelected ? selectedColor : .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(iconImageView.snp.width)
        }
        
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .white
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func bind(_ type: PhotoEditAdjustMode) {
        iconImageView.image = type.icon?.withRenderingMode(.alwaysTemplate)
        nameLabel.text = type.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

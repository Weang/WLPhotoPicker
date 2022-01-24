//
//  PhotoEditFilterCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

class PhotoEditFilterCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    private let nameLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            let selectedColor = WLPhotoUIConfig.default.color.primaryColor
            imageView.layer.borderColor = isSelected ? selectedColor.cgColor : UIColor.clear.cgColor
            nameLabel.textColor = isSelected ? selectedColor : .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 4
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .white
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    func bind(_ filter: PhotoEditFilterProvider) {
        nameLabel.text = filter.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

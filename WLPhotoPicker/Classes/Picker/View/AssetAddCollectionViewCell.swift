//
//  AssetAddCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/31.
//

import UIKit

class AssetAddCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = WLPhotoUIConfig.default.color.functionItemBackgroundColor
        
        let addIconView = UIImageView()
        addIconView.image = BundleHelper.imageNamed("add")?.withRenderingMode(.alwaysTemplate)
        addIconView.tintColor = WLPhotoUIConfig.default.color.functionItemForegroundColor
        contentView.addSubview(addIconView)
        addIconView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.bottom.equalTo(contentView.snp.centerY).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        let tipLabel = UILabel()
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textColor = WLPhotoUIConfig.default.color.functionItemForegroundColor
        tipLabel.text = BundleHelper.localizedString(.AddMore)
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(addIconView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

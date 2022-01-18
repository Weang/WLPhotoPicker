//
//  PhotoEditGraffitiColorCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

class PhotoEditGraffitiColorCollectionViewCell: UICollectionViewCell {
    
    let colorBackgroundView = UIView()
    let colorForegroundView = UIView()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                colorBackgroundView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                colorForegroundView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            } else {
                colorBackgroundView.transform = .identity
                colorForegroundView.transform = .identity
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorBackgroundView.layer.cornerRadius = 10
        colorBackgroundView.backgroundColor = .white
        contentView.addSubview(colorBackgroundView)
        colorBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        colorForegroundView.layer.cornerRadius = 8
        contentView.addSubview(colorForegroundView)
        colorForegroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

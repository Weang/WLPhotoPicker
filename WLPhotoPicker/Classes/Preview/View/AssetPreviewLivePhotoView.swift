//
//  AssetPreviewLivePhotoView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/31.
//

import UIKit

class AssetPreviewLivePhotoView: VisualEffectView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        let imageView = UIImageView()
        imageView.tintColor = WLPhotoPickerUIConfig.default.textColor
        imageView.image = BundleHelper.imageNamed("livephoto")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        let tipLabel = UILabel()
        tipLabel.textColor = WLPhotoPickerUIConfig.default.textColor
        tipLabel.text = "实况"
        tipLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(4)
            make.right.equalTo(-8)
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 26)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

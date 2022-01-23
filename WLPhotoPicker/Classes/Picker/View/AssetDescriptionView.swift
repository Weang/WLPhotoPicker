//
//  AssetDescriptionView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit

class AssetDescriptionView: UIView {
    
    private let iconImageView = UIImageView()
    private let GIFLabel = UILabel()
    private let videoDurationLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(gradientLayer)
        
        GIFLabel.text = "GIF"
        GIFLabel.textColor = .white
        GIFLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(GIFLabel)
        GIFLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        videoDurationLabel.textColor = .white
        videoDurationLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func bind(_ asset: AssetModel) {
        isHidden = !(asset.mediaType == .GIF || asset.mediaType == .video || asset.hasEdit)
        GIFLabel.isHidden = asset.mediaType != .GIF
        videoDurationLabel.text = asset.videoDuration
        if asset.hasEdit  {
            iconImageView.image = BundleHelper.imageNamed("photo_edited")?.withRenderingMode(.alwaysTemplate)
        } else if asset.asset.isVideo {
            iconImageView.image = BundleHelper.imageNamed("video")?.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = nil
        }
    }
    
    func bindPreview(_ asset: AssetModel) {
        bind(asset)
        videoDurationLabel.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor(white: 0, alpha: 0).cgColor,
                                UIColor(white: 0, alpha: 0.7).cgColor]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

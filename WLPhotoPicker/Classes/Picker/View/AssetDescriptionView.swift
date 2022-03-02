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
        GIFLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(GIFLabel)
        GIFLabel.snp.makeConstraints { make in
            make.left.equalTo(6)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(GIFLabel.snp.left)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        videoDurationLabel.textColor = .white
        videoDurationLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func bind(_ asset: AssetModel) {
        isHidden = !(asset.mediaType == .GIF || asset.mediaType == .video || asset.mediaType == .livePhoto || asset.hasEdit)
        GIFLabel.isHidden = asset.mediaType != .GIF
        videoDurationLabel.text = asset.videoDuration
        iconImageView.isHidden = false
        if asset.hasEdit  {
            iconImageView.image = BundleHelper.imageNamed("photo_edited")?.withRenderingMode(.alwaysTemplate)
        } else if asset.asset.isVideo {
            iconImageView.image = BundleHelper.imageNamed("video")?.withRenderingMode(.alwaysTemplate)
        } else if asset.asset.isLivePhoto {
            iconImageView.image = BundleHelper.imageNamed("livephoto")?.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = nil
            iconImageView.isHidden = true
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

//
//  AssetPreviewICloudView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/27.
//

import UIKit

class AssetPreviewICloudView: UIView {
    
    private let imageView = UIImageView()
    private let progressLabel = UILabel()
    
    var progress: Double = 0 {
        didSet {
            var text = "iCloud同步中"
            if progress > 0 {
                text += String(format: "%d%%", Int(progress * 100))
            }
            progressLabel.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        backgroundView.contentView.backgroundColor = WLPhotoUIConfig.default.color.previewTipBackground.withAlphaComponent(0.8)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.tintColor = WLPhotoUIConfig.default.color.textColor
        imageView.image = BundleHelper.imageNamed("icloud")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        progressLabel.textColor = WLPhotoUIConfig.default.color.textColor
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
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

//
//  AssetPreviewICloudView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/27.
//

import UIKit

public class AssetPreviewICloudView: VisualEffectView {
    
    private let imageView = UIImageView()
    private let progressLabel = UILabel()
    
    public var progress: Double = 0 {
        didSet {
            progressLabel.text = String(format: "iCloud同步中%d%%", Int(progress * 100))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        imageView.tintColor = WLPhotoPickerUIConfig.default.textColor
        imageView.image = BundleHelper.imageNamed("icloud")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        progressLabel.textColor = WLPhotoPickerUIConfig.default.textColor
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(4)
            make.right.equalTo(-8)
        }
        
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 26)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  AssetPickerLimitedPermissionView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/31.
//

import UIKit

class AssetPickerLimitedPermissionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let warningIconView = UIImageView()
        warningIconView.image = BundleHelper.imageNamed("warning")?.withRenderingMode(.alwaysTemplate)
        warningIconView.tintColor = #colorLiteral(red: 1, green: 0.7297301888, blue: 0, alpha: 1)
        warningIconView.contentMode = .scaleAspectFit
        addSubview(warningIconView)
        warningIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
            make.left.equalTo(16)
        }
        
        let arrowImageView = UIImageView()
        arrowImageView.transform = CGAffineTransform(rotationAngle: Double.pi)
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.image = BundleHelper.imageNamed("arrow_left")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = WLPhotoPickerUIConfig.default.textColor
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(12)
            make.right.equalTo(-12)
        }
        
        let tipLabel = UILabel()
        tipLabel.numberOfLines = 0
        tipLabel.textColor = WLPhotoPickerUIConfig.default.textColor
        tipLabel.text = "你已设置\(UIApplication.shared.appName ?? "")只能访问相册部分照片，建议允许访问「所有照片」"
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(warningIconView.snp.right).offset(16)
            make.right.equalTo(arrowImageView.snp.left).offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

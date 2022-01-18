//
//  AssetPickerDeniedPermissionView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/31.
//

import UIKit

class AssetPickerDeniedPermissionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleLabel = UILabel()
        titleLabel.text = "无法访问相册中照片"
        titleLabel.textColor = WLPhotoPickerUIConfig.default.textColor
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(keyWindowSafeAreaInsets.top + 120)
        }
        
        let tipLabel = UILabel()
        tipLabel.text = "您已关闭\(UIApplication.shared.appName ?? "")照片访问权限，建议允许访问「所有照片」"
        tipLabel.numberOfLines = 2
        tipLabel.textColor = WLPhotoPickerUIConfig.default.textColor
        tipLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tipLabel.textAlignment = .center
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.width.equalTo(snp.width).multipliedBy(0.7)
        }
        
        let openSettingButton = UIButton()
        openSettingButton.layer.cornerRadius = 5
        openSettingButton.layer.masksToBounds = true
        openSettingButton.setBackgroundImage(UIImage.imageWithColor(WLPhotoPickerUIConfig.default.themeColor), for: .normal)
        openSettingButton.setTitleColor(.white, for: .normal)
        openSettingButton.setTitle("前往系统设置", for: .normal)
        openSettingButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        openSettingButton.addTarget(self, action: #selector(openSetting), for: .touchUpInside)
        addSubview(openSettingButton)
        openSettingButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-keyWindowSafeAreaInsets.bottom - 80)
            make.width.equalTo(160)
            make.height.equalTo(44)
        }
    }
    
    @objc func openSetting() {
        UIApplication.shared.openSetting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

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
        titleLabel.text = BundleHelper.localizedString(.UnableToAccessAlbum)
        titleLabel.textColor = WLPhotoUIConfig.default.color.textColor
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(keyWindowSafeAreaInsets.top + 120)
        }
        
        let tipLabel = UILabel()
        tipLabel.text = BundleHelper.localizedString(.AlbumPermissionDeniedAlert, UIApplication.shared.appName ?? "")
        tipLabel.numberOfLines = 0
        tipLabel.textColor = WLPhotoUIConfig.default.color.textColor
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
        openSettingButton.setBackgroundImage(UIImage.imageWithColor(WLPhotoUIConfig.default.color.primaryColor), for: .normal)
        openSettingButton.setTitleColor(.white, for: .normal)
        openSettingButton.setTitle(BundleHelper.localizedString(.GoSetting), for: .normal)
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

//
//  AssetPreviewNavigationBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

public protocol AssetPreviewNavigationBarDelegate: AnyObject {
    func navigationBarDidClickCancelButton(_ navigationBar: AssetPreviewNavigationBar)
    func navigationBar(_ navigationBar: AssetPreviewNavigationBar, didClickSelectButton isSelected: Bool)
}

public class AssetPreviewNavigationBar: VisualEffectView {
    
    weak var delegate: AssetPreviewNavigationBarDelegate?
    
    let pickerConfig: PickerConfig
    
    private let cancelButton = UIButton()
    private let selectButton = CircleSelectedButton()
    
    init(pickerConfig: PickerConfig) {
        self.pickerConfig = pickerConfig
        super.init(frame: .zero)
        
        cancelButton.setImage(BundleHelper.imageNamed("arrow_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.tintColor = WLPhotoPickerUIConfig.default.textColor
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(snp.bottom).offset(-22)
            make.left.equalTo(20)
            make.height.equalTo(32)
            make.width.equalTo(32)
        }
        
        if pickerConfig.showSelectButton {
            selectButton.addTarget(self, action: #selector(selectButtonClick), for: .touchUpInside)
            selectButton.isSelected = false
            addSubview(selectButton)
            selectButton.snp.makeConstraints { make in
                make.centerY.equalTo(snp.bottom).offset(-22)
                make.right.equalTo(-12)
                make.height.width.equalTo(40)
            }
        }
    }
    
    func setCircleButton(isSelected: Bool, selectedIndex: Int, animated: Bool) {
        selectButton.set(isSelected: isSelected, selectedIndex: selectedIndex, animated: animated)
    }
    
    @objc func cancelButtonClick() {
        delegate?.navigationBarDidClickCancelButton(self)
    }
    
    @objc func selectButtonClick() {
        delegate?.navigationBar(self, didClickSelectButton: !selectButton.isSelected)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.width, height: 44 + keyWindowSafeAreaInsets.top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

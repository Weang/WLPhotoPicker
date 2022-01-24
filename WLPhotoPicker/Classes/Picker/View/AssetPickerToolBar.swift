//
//  AssetPickerToolBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit

protocol AssetPickerToolBarDelegate: AnyObject {
    func pickerToolBarDidClickPermissionLimitedView(_ toolBar: AssetPickerToolBar)
    func pickerToolBarDidClickOrginButton(_ toolBar: AssetPickerToolBar, isOriginal: Bool)
    func pickerToolBarDidClickDoneButton(_ toolBar: AssetPickerToolBar)
}

class AssetPickerToolBar: UIView {
    
    private let limitedPermissionViewHeight: CGFloat = 64
    private let toolBarHeight: CGFloat = 54
    
    weak var delegate: AssetPickerToolBarDelegate?
    
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let contentView = UIStackView()
    private let originButton = NormalStyleButton()
    private let doneButton = UIButton()
    private let limitedPermissionView = AssetPickerLimitedPermissionView()
    
    var isOriginal: Bool = false {
        didSet {
            originButton.isSelected = isOriginal
        }
    }
    
    var isLimitedPermission: Bool = false {
        didSet {
            updateHidden()
        }
    }
    
    var isEnabled: Bool = false {
        didSet {
            doneButton.isEnabled = isEnabled
        }
    }
    
    var showOriginButton: Bool = false {
        didSet {
            originButton.isHidden = !showOriginButton
        }
    }
    
    private let pickerConfig: PickerConfig
    
    init(pickerConfig: PickerConfig) {
        self.pickerConfig = pickerConfig
        super.init(frame: .zero)
        
        backgroundView.contentView.backgroundColor = WLPhotoUIConfig.default.color.toolBarColor.withAlphaComponent(0.8)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        limitedPermissionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(permissionLimitedViewClick)))
        limitedPermissionView.isHidden = true
        addSubview(limitedPermissionView)
        limitedPermissionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(limitedPermissionViewHeight)
        }
        
        contentView.axis = .horizontal
        contentView.distribution = .equalSpacing
        contentView.alignment = .center
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-keyWindowSafeAreaInsets.bottom)
            make.height.equalTo(toolBarHeight)
        }
        
        if pickerConfig.allowSelectOriginal {
            originButton.setImage(BundleHelper.imageNamed("select_normal"), for: .normal)
            originButton.setImage(BundleHelper.imageNamed("select_fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
            originButton.tintColor = WLPhotoUIConfig.default.color.primaryColor
            originButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            originButton.setTitleColor(WLPhotoUIConfig.default.color.textColor, for: .normal)
            originButton.setTitle("原图", for: .normal)
            originButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            originButton.addTarget(self, action: #selector(originButtonClick), for: .touchUpInside)
            contentView.addArrangedSubview(originButton)
        }
        
        contentView.addArrangedSubview(UIView())
        
        if pickerConfig.showPickerDoneButton {
            doneButton.isEnabled = false
            doneButton.layer.cornerRadius = 4
            doneButton.layer.masksToBounds = true
            doneButton.setBackgroundImage(UIImage.imageWithColor(WLPhotoUIConfig.default.color.primaryColor), for: .normal)
            doneButton.setTitle("完成", for: .normal)
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
            contentView.addArrangedSubview(doneButton)
            doneButton.snp.makeConstraints { make in
                make.height.equalTo(30)
                make.width.equalTo(56)
            }
        }
        
        updateHidden()
    }
    
    private func updateHidden() {
        contentView.isHidden = !pickerConfig.allowSelectOriginal && !pickerConfig.showPickerDoneButton
        limitedPermissionView.isHidden = !isLimitedPermission
        isHidden = contentView.isHidden && limitedPermissionView.isHidden
        backgroundView.isHidden = isHidden
        invalidateIntrinsicContentSize()
    }
    
    @objc private func permissionLimitedViewClick() {
        delegate?.pickerToolBarDidClickPermissionLimitedView(self)
    }
    
    @objc private func originButtonClick() {
        originButton.isSelected.toggle()
        delegate?.pickerToolBarDidClickOrginButton(self, isOriginal: originButton.isSelected)
    }
    
    @objc private func doneButtonClick() {
        delegate?.pickerToolBarDidClickDoneButton(self)
    }
    
    override var intrinsicContentSize: CGSize {
        var height = keyWindowSafeAreaInsets.bottom
        if !contentView.isHidden {
            height += toolBarHeight
        }
        if isLimitedPermission {
            height += limitedPermissionViewHeight
        }
        return CGSize(width: UIScreen.width, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PhotoEditCropToolBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

protocol PhotoEditCropToolBarDelegate: AnyObject {
    func toolBarDidClickCancelButton(_ toolBar: PhotoEditCropToolBar)
    func toolBarDidClickRotateLeftButton(_ toolBar: PhotoEditCropToolBar)
    func toolBarDidClickResetButton(_ toolBar: PhotoEditCropToolBar)
    func toolBarDidClickRotateRightButton(_ toolBar: PhotoEditCropToolBar)
    func toolBarDidClickDoneButton(_ toolBar: PhotoEditCropToolBar)
}

class PhotoEditCropToolBar: UIView {

    weak var delegate: PhotoEditCropToolBarDelegate?
    
    private let toolBarHeight: CGFloat = 54
    
    var isEnabled: Bool = true {
        didSet {
            cancelButton.isEnabled = isEnabled
            rotateLeftButton.isEnabled = isEnabled
            resetButton.isEnabled = isEnabled
            rotateRightButton.isEnabled = isEnabled
            doneButton.isEnabled = isEnabled
        }
    }
    
    let toolBarContentView = UIStackView()
    let cancelButton = UIButton()
    let rotateLeftButton = UIButton()
    let resetButton = UIButton()
    let rotateRightButton = UIButton()
    let doneButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        toolBarContentView.axis = .horizontal
        toolBarContentView.distribution = .equalSpacing
        toolBarContentView.alignment = .center
        addSubview(toolBarContentView)
        toolBarContentView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(toolBarHeight)
            make.bottom.equalTo(-keyWindowSafeAreaInsets.bottom)
        }
        
        cancelButton.setTitle(BundleHelper.localizedString(.Cancel), for: .normal)
        cancelButton.setTitleColor(#colorLiteral(red: 0.006965646986, green: 0.474057734, blue: 0.9945388436, alpha: 1), for: .normal)
        cancelButton.setTitleColor(#colorLiteral(red: 0.09823247045, green: 0.2345426977, blue: 0.5038310289, alpha: 1), for: .disabled)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(cancelButton)
        
        rotateLeftButton.tintColor = .white
        rotateLeftButton.setImage(BundleHelper.imageNamed("rotate_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rotateLeftButton.setTitleColor(.white, for: .normal)
        rotateLeftButton.addTarget(self, action: #selector(rotateLeftButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(rotateLeftButton)
        rotateLeftButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(32)
        }
        
        resetButton.tintColor = .white
        resetButton.setImage(BundleHelper.imageNamed("crop_reset")?.withRenderingMode(.alwaysTemplate), for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(resetButton)
        resetButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(32)
        }
        
        rotateRightButton.tintColor = .white
        rotateRightButton.setImage(BundleHelper.imageNamed("rotate_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rotateRightButton.addTarget(self, action: #selector(rotateRightButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(rotateRightButton)
        rotateRightButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(32)
        }
        
        doneButton.setTitle(BundleHelper.localizedString(.Confirm), for: .normal)
        doneButton.setTitleColor(#colorLiteral(red: 0.9805411696, green: 0.7804852724, blue: 0.001862275065, alpha: 1), for: .normal)
        doneButton.setTitleColor(#colorLiteral(red: 0.4722431898, green: 0.3890330195, blue: 0, alpha: 1), for: .disabled)
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(doneButton)
    }
    
    @objc func cancelButtonClick() {
        delegate?.toolBarDidClickCancelButton(self)
    }
    
    @objc func rotateLeftButtonClick() {
        delegate?.toolBarDidClickRotateLeftButton(self)
    }
    
    @objc func resetButtonClick() {
        delegate?.toolBarDidClickResetButton(self)
    }
    
    @objc func rotateRightButtonClick() {
        delegate?.toolBarDidClickRotateRightButton(self)
    }
    
    @objc func doneButtonClick() {
        delegate?.toolBarDidClickDoneButton(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.width, height: toolBarHeight + keyWindowSafeAreaInsets.bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

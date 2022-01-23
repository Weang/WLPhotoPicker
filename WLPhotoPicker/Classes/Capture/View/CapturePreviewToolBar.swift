//
//  CapturePreviewToolBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/17.
//

import UIKit

protocol CapturePreviewToolBarDelegate: AnyObject {
    func toolBarDidClickCancelButton(_ toolBar: CapturePreviewToolBar)
    func toolBarDidClickDoneButton(_ toolBar: CapturePreviewToolBar)
}

class CapturePreviewToolBar: UIView {
    
    weak var delegate: CapturePreviewToolBarDelegate?
    
    private let toolBarHeight: CGFloat = 54
    
    private let toolBarContentView = UIStackView()
    private let cancelButton = UIButton()
    private let doneButton = UIButton()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        
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
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(cancelButton)
        
        doneButton.setTitle("确定", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(doneButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor(white: 0, alpha: 0).cgColor,
                                UIColor(white: 0, alpha: 0.4).cgColor]
        gradientLayer.removeAllAnimations()
    }
    
    @objc private func cancelButtonClick() {
        delegate?.toolBarDidClickCancelButton(self)
    }
    
    @objc private func doneButtonClick() {
        delegate?.toolBarDidClickDoneButton(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.width, height: toolBarHeight + keyWindowSafeAreaInsets.bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

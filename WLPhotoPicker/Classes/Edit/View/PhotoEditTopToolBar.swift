//
//  PhotoEditTopToolBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

protocol PhotoEditTopToolBarDelegate: AnyObject {
    func topToolBarDidClickCancelButton(_ topToolBar: PhotoEditTopToolBar)
}

class PhotoEditTopToolBar: UIView {
    
    weak var delegate: PhotoEditTopToolBarDelegate?
    
    private let toolBarHeight: CGFloat = 60
    
    private let cancelButton = UIButton()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        
        cancelButton.tintColor = .white
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        cancelButton.setImage(BundleHelper.imageNamed("back_fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalTo(self.snp.top).offset(22 + keyWindowSafeAreaInsets.top)
            make.height.width.width.equalTo(32)
        }
        
    }
    
    @objc private func cancelButtonClick() {
        delegate?.topToolBarDidClickCancelButton(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor(white: 0, alpha: 0.4).cgColor,
                                UIColor(white: 0, alpha: 0).cgColor]
        gradientLayer.removeAllAnimations()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.width, height: toolBarHeight + keyWindowSafeAreaInsets.top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

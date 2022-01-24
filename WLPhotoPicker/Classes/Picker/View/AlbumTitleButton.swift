//
//  AlbumTitleButton.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

class AlbumTitleButton: UIControl {
    
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi * -0.5 + (self.isSelected ? .pi : 0))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(32)
        }
        
        arrowImageView.transform = CGAffineTransform(rotationAngle: Double.pi * -0.5)
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.image = BundleHelper.imageNamed("arrow_left")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = WLPhotoUIConfig.default.color.textColor
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(12)
            make.right.equalTo(-12)
        }
        
        titleLabel.isUserInteractionEnabled = false
        titleLabel.textColor = WLPhotoUIConfig.default.color.textColor
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(arrowImageView.snp.left).offset(-6)
        }
        
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

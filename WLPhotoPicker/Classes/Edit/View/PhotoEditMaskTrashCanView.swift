//
//  PhotoEditMaskTrashCanView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/10.
//

import UIKit

class PhotoEditMaskTrashCanView: UIView {
    
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let iconView = UIImageView()
    let tipLabel = UILabel()
    
    var isHighlighted: Bool = false {
        didSet {
            backgroundView.contentView.backgroundColor = isHighlighted ? #colorLiteral(red: 0.8771282434, green: 0.299628377, blue: 0.2993704677, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).withAlphaComponent(0.9)
            iconView.isHighlighted = isHighlighted
            tipLabel.text = isHighlighted ? "松开手指删除" : "拖到这里删除"
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        isUserInteractionEnabled = false
        
        backgroundView.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).withAlphaComponent(0.9)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        iconView.tintColor = .white
        iconView.image = BundleHelper.imageNamed("trashcan")?.withRenderingMode(.alwaysTemplate)
        iconView.highlightedImage = BundleHelper.imageNamed("trashcan_open")?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(13)
            make.width.height.equalTo(24)
        }
        
        tipLabel.text = "拖到这里删除"
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-13)
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 160, height: 80)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

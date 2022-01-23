//
//  VisualEffectView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/23.
//

import UIKit

class VisualEffectView: UIView {
    
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView.contentView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1).withAlphaComponent(0.8)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

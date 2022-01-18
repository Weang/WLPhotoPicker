//
//  PhotoEditMaskView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/9.
//

import UIKit

public class PhotoEditMaskView: UIView {
    
    var isActive: Bool = false
    var maskLayer: PhotoEditMaskLayer
    
    let maskImageView = UIImageView()
    
    init(maskLayer: PhotoEditMaskLayer) {
        self.maskLayer = maskLayer
        super.init(frame: .zero)
        
        size = maskLayer.size
        center = maskLayer.center
        backgroundColor = .clear
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
        
        addSubview(maskImageView)
        maskImageView.snp.makeConstraints { make in
            make.left.top.equalTo(maskLayer.maskPadding)
            make.bottom.right.equalTo(-maskLayer.maskPadding)
        }
    }
    
    func reset() {
        transform = .identity
        size = maskLayer.size
        center = maskLayer.center
    }
    
    func updateMaskLayer(showActive: Bool = true, dismissLater: Bool = true, animate: Bool = false, completion: (() -> Void)? = nil) {
        if showActive {
            self.showActive(dismissLater: dismissLater)
        }
        maskImageView.image = maskLayer.maskImage
        maskLayer.scale = max(0.5, min(maskLayer.scale, 3))
        
        let transform = CGAffineTransform(translationX: maskLayer.translation.x, y: maskLayer.translation.y)
            .scaledBy(x: maskLayer.scale, y: maskLayer.scale)
            .rotated(by: maskLayer.rotation)
        if animate {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = transform
            }, completion: { _ in
                completion?()
            })
        } else {
            self.transform = transform
            completion?()
        }
        
    }
    
    func showActive(dismissLater: Bool = true) {
        isActive = true
        layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if dismissLater {
            perform(#selector(dismissActive), with: nil, afterDelay: 2)
        }
    }
    
    @objc func dismissActive() {
        isActive = false
        layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

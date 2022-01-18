//
//  PhotoEditCropCoverView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/14.
//

import UIKit

class PhotoEditCropCoverView: UIVisualEffectView {

    var maskRect: CGRect = .zero {
        didSet {
            
        }
    }
    
    let maskLayer = CAShapeLayer()
    
    init() {
        super.init(effect: UIBlurEffect(style: .light))
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer
    }
    
    func drawMask() {
        let fillPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
        let maskPath = UIBezierPath(roundedRect: maskRect, cornerRadius: 0)
        fillPath.append(maskPath)
        fillPath.usesEvenOddFillRule = true
        maskLayer.path = fillPath.cgPath
    }
    
    func setCoverHidden(_ isHidden: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if isHidden {
            self.effect = nil
        } else {
            perform(#selector(hideCover), with: nil, afterDelay: 1)
        }
    }
    
    @objc func hideCover() {
        UIView.animate(withDuration: 0.4) {
            self.effect = UIBlurEffect(style: .dark)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

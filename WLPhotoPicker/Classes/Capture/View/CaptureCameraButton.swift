//
//  CaptureCameraButton.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/2.
//

import UIKit

public class CaptureCameraButton: UIView {
    
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    private let buttonCenterView = UIView()
    private let progressLayer = CAShapeLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView.layer.cornerRadius = intrinsicContentSize.width * 0.5
        backgroundView.layer.masksToBounds = true
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let buttonCenterViewWidth = intrinsicContentSize.width - 20
        buttonCenterView.layer.cornerRadius = buttonCenterViewWidth * 0.5
        buttonCenterView.backgroundColor = .white
        backgroundView.contentView.addSubview(buttonCenterView)
        buttonCenterView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(buttonCenterViewWidth)
        }
        
        let progressLayerCenter = intrinsicContentSize.width * 0.5
        let progressLayerRadius = progressLayerCenter - 2.5
        let path = UIBezierPath(arcCenter: CGPoint(x: progressLayerCenter, y: progressLayerCenter),
                                radius: progressLayerRadius,
                                startAngle: .pi * -0.5,
                                endAngle: .pi * 1.5,
                                clockwise: true)

        progressLayer.frame = CGRect(origin: .zero, size: intrinsicContentSize)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineCap = .square
        progressLayer.path = path.cgPath
        progressLayer.lineWidth = 5
        progressLayer.strokeEnd = 0
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = progressLayer.frame
        gradientLayer.colors = [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor, #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
    }
    
    public func showBeginAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.buttonCenterView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
    }
    
    public func showEndAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = .identity
            self.buttonCenterView.transform = .identity
        })
        progressLayer.strokeEnd = 0
        progressLayer.removeAllAnimations()
    }
    
    public func updateProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

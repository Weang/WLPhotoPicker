//
//  LoadingHUD.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit

class LoadingHUD {
    
    static let shared = LoadingHUD()
    
    private var window: UIWindow?
    private weak var HUDView: LoadingHUDView?
    
    private init() { }
    
    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        window?.isHidden = false
        
        let view = LoadingHUDView(frame: UIScreen.main.bounds)
        window?.addSubview(view)
        HUDView = view
    }
    
    func showLoading() {
        if HUDView == nil {
            createWindow()
        }
        HUDView?.showLoading()
    }
    
    func showProgress(_ progress: CGFloat) {
        if HUDView == nil {
            createWindow()
        }
        HUDView?.showProgress(progress)
    }
    
    func hideLoading() {
        window = nil
    }
    
}

fileprivate class LoadingHUDView: UIView {
    
    private let contentView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    private let progressView = LoadingProgressView()
    private let tipLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).withAlphaComponent(0.6)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(108)
            make.width.equalTo(140)
        }
        
        progressView.isHidden = true
        contentView.contentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(20)
            make.height.width.equalTo(30)
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = .white
        activityIndicator.style = .whiteLarge
        contentView.contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(progressView.snp.center)
        }
        
        tipLabel.text = BundleHelper.localizedString(.Processing)
        tipLabel.textColor = .white
        tipLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
        
        layoutIfNeeded()
    }
    
    func showLoading() {
        progressView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func showProgress(_ progress: CGFloat) {
        progressView.progress = progress
        activityIndicator.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LoadingProgressView: UIView {
    
    private let progressLayer = CAShapeLayer()
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
            isHidden = progress == 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
       
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.opacity = 1
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.lineWidth = 4
        progressLayer.shadowColor = UIColor.black.cgColor
        progressLayer.shadowOffset = CGSize(width: 1, height: 1)
        progressLayer.shadowRadius = 2
        progressLayer.shadowOpacity = 0.5

        layer.addSublayer(progressLayer)
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.size.width * 0.5, y: rect.size.height * 0.5)
        let radius = rect.size.width * 0.5
        
        let startAngle = -Double.pi / 2
        let endAngle = -Double.pi / 2 + Double.pi * 2 * progress
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        progressLayer.frame = bounds
        progressLayer.path = path.cgPath
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

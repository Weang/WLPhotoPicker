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
    
    private init() { }
    
    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        window?.isHidden = false
        
        let view = LoadingHUDView(frame: UIScreen.main.bounds)
        window?.addSubview(view)
    }
    
    func showLoading() {
        createWindow()
    }
    
    func hideLoading() {
        window = nil
    }
    
}

fileprivate class LoadingHUDView: UIView {
    
    private let contnetView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        contnetView.contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
        contnetView.layer.cornerRadius = 10
        contnetView.layer.masksToBounds = true
        addSubview(contnetView)
        contnetView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalTo(120)
        }
        
        activityIndicator.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        activityIndicator.startAnimating()
        activityIndicator.tintColor = .white
        activityIndicator.style = .whiteLarge
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

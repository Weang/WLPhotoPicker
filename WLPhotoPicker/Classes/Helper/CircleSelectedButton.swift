//
//  CircleSelectedButton.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit

class CircleSelectedButton: UIControl {
    
    private let buttonSize: CGFloat = 24
    private let unselectedCurcle = UIView()
    private let selectedCurcle = UIView()
    private let numebrLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            unselectedCurcle.isHidden = isSelected
            selectedCurcle.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        unselectedCurcle.isUserInteractionEnabled = false
        unselectedCurcle.layer.borderColor = WLPhotoUIConfig.default.color.textColorDark.cgColor
        unselectedCurcle.layer.borderWidth = 0.5 * UIScreen.main.scale
        unselectedCurcle.backgroundColor = UIColor(white: 0, alpha: 0.4)
        addSubview(unselectedCurcle)
        unselectedCurcle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(buttonSize)
        }
        
        selectedCurcle.isUserInteractionEnabled = false
        selectedCurcle.backgroundColor = WLPhotoUIConfig.default.color.primaryColor
        selectedCurcle.layer.masksToBounds = true
        addSubview(selectedCurcle)
        selectedCurcle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(buttonSize)
        }
        
        numebrLabel.textColor = WLPhotoUIConfig.default.color.textColorDark
        numebrLabel.font = UIFont.systemFont(ofSize: 14)
        selectedCurcle.addSubview(numebrLabel)
        numebrLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func set(isSelected: Bool, selectedIndex: Int, animated: Bool) {
        self.isSelected = isSelected
        numebrLabel.text = "\(selectedIndex)"
        if animated {
            showSelectedAnimation()
        }
    }
    
    private func showSelectedAnimation() {
        selectedCurcle.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: .curveEaseInOut) {
            self.selectedCurcle.transform = .identity
        } completion: { _ in
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        unselectedCurcle.layer.cornerRadius = unselectedCurcle.height * 0.5
        selectedCurcle.layer.cornerRadius = selectedCurcle.height * 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PhotoEditAdjustSlideView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

public class PhotoEditAdjustSlideView: UIControl {
    
    public var minimumValue: CGFloat = -1 {
        didSet {
            layoutSlider()
        }
    }
    
    public var maximumValue: CGFloat = 1 {
        didSet {
            layoutSlider()
        }
    }
    
    public var value: Double = 0 {
        didSet {
            layoutSlider()
        }
    }
    
    var sliderWidth: CGFloat {
        sliderLine.width - sliderBar.width
    }
    
    private let sliderLine = UIView()
    private let sliderBar = UIView()
    private let valueLabel = UILabel()
    private let highlightView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        layoutIfNeeded()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    func setupView() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 4
        
        sliderLine.layer.cornerRadius = 2
        sliderLine.backgroundColor = .white
        addSubview(sliderLine)
        sliderLine.snp.makeConstraints { make in
            make.centerY.equalTo(snp.bottom).offset(-10)
            make.height.equalTo(4)
            make.left.right.equalToSuperview()
        }
        
        highlightView.layer.cornerRadius = 2
        highlightView.backgroundColor = WLPhotoPickerUIConfig.default.themeColor
        sliderLine.addSubview(highlightView)
        
        sliderBar.layer.cornerRadius = 10
        sliderBar.backgroundColor = .white
        addSubview(sliderBar)
        sliderBar.snp.makeConstraints { make in
            make.centerY.equalTo(sliderLine.snp.centerY)
            make.height.width.equalTo(20)
            make.centerX.equalTo(snp.centerX).offset(0)
        }
        
        valueLabel.textColor = .white
        valueLabel.text = "0"
        valueLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(sliderBar.snp.centerX)
        }
    }
    
    func layoutSlider() {
        valueLabel.text = "\(Int(value * 100))"
        let offsetWidth = sliderWidth / (maximumValue - minimumValue) * value
        sliderBar.snp.updateConstraints { make in
            if minimumValue == 0 {
                make.centerX.equalTo(snp.centerX).offset(offsetWidth - sliderWidth * 0.5)
            } else {
                make.centerX.equalTo(snp.centerX).offset(offsetWidth)
            }
        }
        highlightView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(abs(offsetWidth) + sliderBar.width * 0.5)
            if minimumValue == 0 {
                make.left.equalToSuperview()
            } else {
                if offsetWidth < 0 {
                    make.right.equalTo(snp.centerX)
                } else {
                    make.left.equalTo(snp.centerX)
                }
            }
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        var value = (location.x - sliderBar.width * 0.5) / sliderWidth * (maximumValue - minimumValue)
        if minimumValue < 0 {
            value = value - (maximumValue - minimumValue) * 0.5
        }
        value = min(max(value, minimumValue), maximumValue)
        self.value = Double(Int(value * 100)) / 100
        self.sendActions(for: .valueChanged)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 42)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

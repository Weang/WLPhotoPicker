//
//  PhotoEditCropRectangleView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

protocol PhotoEditCropRectangleViewDelegate: AnyObject {
    func cropView(_ cropView: PhotoEditCropRectangleView, didCropToRect cropRect: CGRect)
}

class PhotoEditCropRectangleView: UIView {
    
    weak var delegate: PhotoEditCropRectangleViewDelegate?
    
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let fillLayer = CAShapeLayer()
    
    let cropContentView = UIView()
    let lineLayer = CAShapeLayer()
    
    let leftTopCorner = PhotoEditCropRectangleCorner(posotion: .leftTop)
    let rightTopCorner = PhotoEditCropRectangleCorner(posotion: .rightTop)
    let rightBottomCorner = PhotoEditCropRectangleCorner(posotion: .rightBottom)
    let leftBottomCorner = PhotoEditCropRectangleCorner(posotion: .leftBottom)
    
    var minimumSize: CGFloat = 46
    var startCropRect: CGRect = .zero
    var cropRect: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView() {
        isUserInteractionEnabled = true
        
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        fillLayer.fillRule = .evenOdd
        backgroundView.layer.mask = fillLayer
        
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = UIColor.white.cgColor
        cropContentView.layer.addSublayer(lineLayer)
        
        cropContentView.isUserInteractionEnabled = true
        cropContentView.backgroundColor = .clear
        addSubview(cropContentView)
        
        addSubview(leftTopCorner)
        leftTopCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropContentView.snp.left)
            make.centerY.equalTo(cropContentView.snp.top)
        }
        
        addSubview(rightTopCorner)
        rightTopCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropContentView.snp.right)
            make.centerY.equalTo(cropContentView.snp.top)
        }
        
        addSubview(rightBottomCorner)
        rightBottomCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropContentView.snp.right)
            make.centerY.equalTo(cropContentView.snp.bottom)
        }
        
        addSubview(leftBottomCorner)
        leftBottomCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropContentView.snp.left)
            make.centerY.equalTo(cropContentView.snp.bottom)
        }
        
        leftTopCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        rightTopCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        rightBottomCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        leftBottomCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            startCrop()
            startCropRect = self.cropRect
        } else if gesture.state == .ended {
            finishCrop()
        }
        let translation = gesture.translation(in: self)
        var cropRect = startCropRect
        if gesture.view == leftTopCorner {
            cropRect.origin.x += translation.x
            cropRect.origin.y += translation.y
            cropRect.size.width -= translation.x
            cropRect.size.height -= translation.y
            if cropRect.size.width <= minimumSize {
                cropRect.origin.x -= (minimumSize - cropRect.size.width)
                cropRect.size.width = minimumSize
            }
            if cropRect.size.height <= minimumSize {
                cropRect.origin.y -= (minimumSize - cropRect.size.height)
                cropRect.size.height = minimumSize
            }
        } else if gesture.view == rightTopCorner {
            cropRect.origin.y +=  translation.y
            cropRect.size.width += translation.x
            cropRect.size.height -=  translation.y
            if cropRect.size.height <= minimumSize {
                cropRect.origin.y -= (minimumSize - cropRect.size.height)
                cropRect.size.height = minimumSize
            }
        } else if gesture.view == rightBottomCorner {
            cropRect.size.width +=  translation.x
            cropRect.size.height +=  translation.y
        } else if gesture.view == leftBottomCorner {
            cropRect.origin.x += translation.x
            cropRect.size.width -= translation.x
            cropRect.size.height +=  translation.y
            if cropRect.size.width <= minimumSize {
                cropRect.origin.x -= (minimumSize - cropRect.size.width)
                cropRect.size.width = minimumSize
            }
        }
        cropRect.size.width = max(cropRect.size.width, minimumSize)
        cropRect.size.height = max(cropRect.size.height, minimumSize)
        updateCropRect(cropRect)
    }
    
    func updateCropRect(_ cropRect: CGRect) {
        self.cropRect = cropRect
        
        cropContentView.frame = cropRect
        
        let fillPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
        let cropPath = UIBezierPath(roundedRect: cropRect, cornerRadius: 0)
        fillPath.append(cropPath)
        fillPath.usesEvenOddFillRule = true
        fillLayer.path = fillPath.cgPath
        
        let linePath = UIBezierPath()
        for i in 0...3 {
            let y = (cropRect.size.height / 3) * CGFloat(i)
            linePath.move(to: CGPoint(x: 0, y: y))
            linePath.addLine(to: CGPoint(x: cropRect.size.width, y: y))
        }
        
        for i in 0...3 {
            let x = (cropRect.size.width / 3) * CGFloat(i)
            linePath.move(to: CGPoint(x: x, y: 0))
            linePath.addLine(to: CGPoint(x: x, y:cropRect.size.height))
        }
        linePath.stroke()
        lineLayer.path = linePath.cgPath
        setNeedsDisplay()
    }
    
    func startCrop() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        setCoverHidden(true)
    }
    
    func finishCrop() {
        perform(#selector(sendFinishEvent), with: nil, afterDelay: 0.5)
    }
    
    @objc func sendFinishEvent() {
        setCoverHidden(false)
        delegate?.cropView(self, didCropToRect: cropRect)
    }
    
    func setCoverHidden(_ isHidden: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if isHidden {
            self.backgroundView.effect = nil
        } else {
            perform(#selector(hideCover), with: nil, afterDelay: 1)
        }
    }
    
    @objc func hideCover() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view?.isKind(of: PhotoEditCropRectangleCorner.self) ?? false {
            return view
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PhotoEditCropRectangleView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

protocol PhotoEditCropRectangleViewDelegate: AnyObject {
    func cropView(_ cropView: PhotoEditCropRectangleView, willCropToRect cropRect: CGRect)
    func cropView(_ cropView: PhotoEditCropRectangleView, didCropToRect cropRect: CGRect)
}

class PhotoEditCropRectangleView: UIView {
    
    weak var delegate: PhotoEditCropRectangleViewDelegate?
    
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let backgroundMaskLayer = CAShapeLayer()
    
    private let cropGridView = UIView()
    private let cropGridLineLayer = CAShapeLayer()
    
    private let leftTopCorner = PhotoEditCropRectangleCorner(posotion: .leftTop)
    private let rightTopCorner = PhotoEditCropRectangleCorner(posotion: .rightTop)
    private let rightBottomCorner = PhotoEditCropRectangleCorner(posotion: .rightBottom)
    private let leftBottomCorner = PhotoEditCropRectangleCorner(posotion: .leftBottom)
    
    private var minimumSize: CGFloat = 46
    private var startCropRect: CGRect = .zero
    
    var cropRect: CGRect = .zero
    var maximumCropRect: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupGesture()
    }
    
    func setupView() {
        isUserInteractionEnabled = true
        
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        cropGridView.isUserInteractionEnabled = true
        cropGridView.backgroundColor = .clear
        addSubview(cropGridView)
        
        addSubview(leftTopCorner)
        leftTopCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropGridView.snp.left)
            make.centerY.equalTo(cropGridView.snp.top)
        }
        
        addSubview(rightTopCorner)
        rightTopCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropGridView.snp.right)
            make.centerY.equalTo(cropGridView.snp.top)
        }
        
        addSubview(rightBottomCorner)
        rightBottomCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropGridView.snp.right)
            make.centerY.equalTo(cropGridView.snp.bottom)
        }
        
        addSubview(leftBottomCorner)
        leftBottomCorner.snp.makeConstraints { make in
            make.centerX.equalTo(cropGridView.snp.left)
            make.centerY.equalTo(cropGridView.snp.bottom)
        }
        
        backgroundMaskLayer.fillRule = .evenOdd
        backgroundView.layer.mask = backgroundMaskLayer
        
        cropGridLineLayer.lineWidth = 1.5
        cropGridLineLayer.strokeColor = UIColor(white: 1, alpha: 0.6).cgColor
        cropGridView.layer.addSublayer(cropGridLineLayer)
    }
    
    func setupGesture() {
        leftTopCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        rightTopCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        rightBottomCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
        leftBottomCorner.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startCropRect = self.cropRect
            hideCover()
        case .changed:
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
                if cropRect.origin.x < maximumCropRect.origin.x {
                    cropRect.size.width -= (maximumCropRect.origin.x - cropRect.origin.x)
                    cropRect.origin.x = maximumCropRect.origin.x
                }
                if cropRect.origin.y < maximumCropRect.origin.y {
                    cropRect.size.height -= (maximumCropRect.origin.y - cropRect.origin.y)
                    cropRect.origin.y = maximumCropRect.origin.y
                }
            } else if gesture.view == rightTopCorner {
                cropRect.origin.y +=  translation.y
                cropRect.size.width += translation.x
                cropRect.size.height -=  translation.y
                if cropRect.size.height <= minimumSize {
                    cropRect.origin.y -= (minimumSize - cropRect.size.height)
                    cropRect.size.height = minimumSize
                }
                if cropRect.origin.y < maximumCropRect.origin.y {
                    cropRect.size.height -= (maximumCropRect.origin.y - cropRect.origin.y)
                    cropRect.origin.y = maximumCropRect.origin.y
                }
                if cropRect.size.width > maximumCropRect.size.width {
                    cropRect.size.width = maximumCropRect.size.width
                }
            } else if gesture.view == rightBottomCorner {
                cropRect.size.width += translation.x
                cropRect.size.height += translation.y
                if cropRect.size.width > maximumCropRect.size.width {
                    cropRect.size.width = maximumCropRect.size.width
                }
                if cropRect.size.height > maximumCropRect.size.height {
                    cropRect.size.height = maximumCropRect.size.height
                }
            } else if gesture.view == leftBottomCorner {
                cropRect.origin.x += translation.x
                cropRect.size.width -= translation.x
                cropRect.size.height +=  translation.y
                if cropRect.size.width <= minimumSize {
                    cropRect.origin.x -= (minimumSize - cropRect.size.width)
                    cropRect.size.width = minimumSize
                }
                if cropRect.origin.x < maximumCropRect.origin.x {
                    cropRect.size.width -= (maximumCropRect.origin.x - cropRect.origin.x)
                    cropRect.origin.x = maximumCropRect.origin.x
                }
                if cropRect.size.height > maximumCropRect.size.height {
                    cropRect.size.height = maximumCropRect.size.height
                }
            }
            cropRect.size.width = max(cropRect.size.width, minimumSize)
            cropRect.size.height = max(cropRect.size.height, minimumSize)
            updateCropRect(cropRect, animate: false)
        default:
            showCoverWithDelay()
        }
    }
    
    func updateCropRect(_ cropRect: CGRect, animate: Bool = true) {
        self.cropRect = cropRect
        
        cropGridView.frame = cropRect
        layoutIfNeeded()
        
        updateLayers(animate: animate)
    }
    
    func updateLayers(animate: Bool) {
        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
        let hollowOutPath = UIBezierPath(roundedRect: cropRect, cornerRadius: 0)
        maskLayerPath.append(hollowOutPath)
        maskLayerPath.usesEvenOddFillRule = true
        backgroundMaskLayer.path = maskLayerPath.cgPath
        
        let lineLayerPath = UIBezierPath()
        for i in 0...3 {
            let y = (cropRect.size.height / 3) * CGFloat(i)
            lineLayerPath.move(to: CGPoint(x: 0, y: y))
            lineLayerPath.addLine(to: CGPoint(x: cropRect.size.width, y: y))
        }
        for i in 0...3 {
            let x = (cropRect.size.width / 3) * CGFloat(i)
            lineLayerPath.move(to: CGPoint(x: x, y: 0))
            lineLayerPath.addLine(to: CGPoint(x: x, y:cropRect.size.height))
        }
        lineLayerPath.stroke()
        cropGridLineLayer.path = lineLayerPath.cgPath
        
        if animate {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = 0.4
            animation.isRemovedOnCompletion = false
            animation.timingFunction = .init(name: .easeInEaseOut)
            backgroundMaskLayer.add(animation, forKey: "animation")
            cropGridLineLayer.add(animation, forKey: "animation")
        }
    }
    
    func hideCover() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        backgroundView.effect = nil
    }
    
    func showCoverWithDelay() {
        delegate?.cropView(self, willCropToRect: cropRect)
        perform(#selector(sendFinishEvent), with: nil, afterDelay: 0.6)
    }
    
    @objc func sendFinishEvent() {
        UIView.animate(withDuration: 0.4) {
            self.backgroundView.effect = UIBlurEffect(style: .dark)
        }
        delegate?.cropView(self, didCropToRect: cropRect)
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

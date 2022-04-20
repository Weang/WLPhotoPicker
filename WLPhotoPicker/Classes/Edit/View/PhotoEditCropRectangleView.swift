//
//  PhotoEditCropRectangleView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

protocol PhotoEditCropRectangleViewDelegate: AnyObject {
    func cropViewDidBeginDrag(_ cropView: PhotoEditCropRectangleView)
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
    
    private let photoEditCropRatios: PhotoEditCropRatio
    private var minimumSize: CGSize = CGSize(width: 46, height: 46)
    private var startCropRect: CGRect = .zero
    
    var cropRect: CGRect = .zero
    var maximumCropRect: CGRect = .zero
    
    init(photoEditCropRatios: PhotoEditCropRatio) {
        self.photoEditCropRatios = photoEditCropRatios
        super.init(frame: .zero)
        
        setupView()
        setupGesture()
        
        if photoEditCropRatios != .freedom {
            let cropRatio = photoEditCropRatios.ratio
            if photoEditCropRatios.ratio > 1 {
                minimumSize = CGSize(width: minimumSize.height * cropRatio, height: minimumSize.height)
            } else {
                minimumSize = CGSize(width: minimumSize.width, height: minimumSize.width / cropRatio)
            }
        }
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
        cropGridLineLayer.shadowColor = UIColor.black.cgColor
        cropGridLineLayer.shadowRadius = 2
        cropGridLineLayer.shadowOpacity = 0.5
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
            delegate?.cropViewDidBeginDrag(self)
        case .changed:
            let translation = gesture.translation(in: self)
            var cropRect = startCropRect
            let cropRatio = photoEditCropRatios.ratio
            
            var maxWidth: CGFloat = 0
            var maxHeight: CGFloat = 0
            if gesture.view == leftTopCorner || gesture.view == leftBottomCorner {
                maxWidth = startCropRect.maxX - maximumCropRect.origin.x
            } else {
                maxWidth = maximumCropRect.size.width
            }
            if gesture.view == leftTopCorner || gesture.view == rightTopCorner {
                maxHeight = startCropRect.maxY - maximumCropRect.origin.y
            } else {
                maxHeight = maximumCropRect.size.height
            }
            if photoEditCropRatios != .freedom {
                maxWidth = min(maxWidth, maxHeight * cropRatio)
                maxHeight = min(maxHeight, maxWidth / cropRatio)
            }
            
            func fitCropRectSize(_ cropRect: inout CGRect) {
                cropRect.size.width = cropRect.size.width.between(min: minimumSize.width, max: maxWidth)
                if photoEditCropRatios == .freedom {
                    cropRect.size.height = cropRect.size.height.between(min: minimumSize.height, max: maxHeight)
                } else {
                    cropRect.size.height = cropRect.size.width / cropRatio
                }
            }
            
            if gesture.view == leftTopCorner {
                cropRect.size.width -= translation.x
                cropRect.size.height -= translation.y
                fitCropRectSize(&cropRect)
                cropRect.origin.x = startCropRect.maxX - cropRect.size.width
                cropRect.origin.y = startCropRect.maxY - cropRect.size.height
            } else if gesture.view == rightTopCorner {
                cropRect.size.width += translation.x
                cropRect.size.height -= translation.y
                fitCropRectSize(&cropRect)
                cropRect.origin.y = startCropRect.maxY - cropRect.size.height
            } else if gesture.view == rightBottomCorner {
                cropRect.size.width += translation.x
                cropRect.size.height += translation.y
                fitCropRectSize(&cropRect)
            } else if gesture.view == leftBottomCorner {
                cropRect.size.width -= translation.x
                cropRect.size.height +=  translation.y
                fitCropRectSize(&cropRect)
                cropRect.origin.x = startCropRect.maxX - cropRect.size.width
            }
            cropRect = cropRect.rounded()
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
        UIGraphicsBeginImageContext(bounds.size)
        defer {
            UIGraphicsEndImageContext()
        }
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

//
//  PhotoEditCropRectangleCorner.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/13.
//

import UIKit

class PhotoEditCropRectangleCorner: UIView {
    
    private let shapeLayer = CAShapeLayer()
    private let posotion: PhotoEditCropRectangleCornerPosition
    
    init(posotion: PhotoEditCropRectangleCornerPosition) {
        self.posotion = posotion
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
        
        self.transform = CGAffineTransform(rotationAngle: posotion.rotationAngle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lineWidth: CGFloat = 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
        path.addLine(to: CGPoint(x: width, y: height * 0.5))
        path.addLine(to: CGPoint(x: width, y: height * 0.5 - lineWidth))
        path.addLine(to: CGPoint(x: width * 0.5 - lineWidth, y: height * 0.5 - lineWidth))
        path.addLine(to: CGPoint(x: width * 0.5 - lineWidth, y: height))
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        path.fill()
        shapeLayer.path = path.cgPath
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 36, height: 36)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum PhotoEditCropRectangleCornerPosition {
    case leftTop
    case rightTop
    case rightBottom
    case leftBottom
}

extension PhotoEditCropRectangleCornerPosition {
    
    var rotationAngle: CGFloat {
        switch self {
        case .leftTop:
            return 0
        case .rightTop:
            return .pi * 0.5
        case .rightBottom:
            return .pi
        case .leftBottom:
            return .pi * 1.5
        }
    }
    
}

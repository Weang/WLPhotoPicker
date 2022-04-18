//
//  PhotoEditMosaicPath.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

struct PhotoEditMosaicPath {
    
    var drawedViewSize: CGSize = .zero
    
    var pathLines: [PhotoEditMosaicPathLine] = []
    
    var last: PhotoEditMosaicPathLine? {
        pathLines.last
    }
    
    mutating func append(pathLine: PhotoEditMosaicPathLine) {
        pathLines.append(pathLine)
    }
    
    mutating func removeLast() {
        if pathLines.count > 0 {
            pathLines.removeLast()
        }
    }
    
    func drawPath() -> CGPath? {
        let mosaicPath = UIBezierPath()
        mosaicPath.lineCapStyle = .round
        mosaicPath.lineJoinStyle = .round
        pathLines.forEach { (path) in
            mosaicPath.lineWidth = path.lineWidth
            mosaicPath.move(to: path.startPoint)
            path.linePoints.forEach { (point) in
                mosaicPath.addLine(to: point)
            }
        }
        return mosaicPath.cgPath
    }
    
    func drawMosaicImage(ornginalImage: UIImage?, mosaicImage: UIImage?) -> UIImage? {
        guard let image = ornginalImage else {
            return nil
        }
        if pathLines.count == 0 {
            return image
        }
        let scale = image.size.width / drawedViewSize.width
        let size = image.size
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(in: rect)
        
        let context = UIGraphicsGetCurrentContext()
        pathLines.forEach { (path) in
            context?.move(to: CGPoint(x: path.startPoint.x * scale, y: path.startPoint.y * scale))
            path.linePoints.forEach { (point) in
                context?.addLine(to: CGPoint(x: point.x * scale, y: point.y * scale))
            }
            context?.setLineWidth(path.lineWidth * scale)
            context?.setLineCap(.round)
            context?.setLineJoin(.round)
            context?.setBlendMode(.clear)
            context?.strokePath()
        }
        guard let maskImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return image
        }
        mosaicImage?.draw(in: rect)
        maskImage.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
}

class PhotoEditMosaicPathLine {
    
    let lineWidth: CGFloat
    let startPoint: CGPoint
    let mosaicPath = UIBezierPath()
    var linePoints: [CGPoint] = []
    
    init(lineWidth: CGFloat, startPoint: CGPoint) {
        self.lineWidth = lineWidth
        self.startPoint = startPoint
        mosaicPath.lineCapStyle = .round
        mosaicPath.lineJoinStyle = .round
        mosaicPath.lineWidth = lineWidth
        mosaicPath.move(to: startPoint)
    }
    
    func addLine(to point: CGPoint) {
        linePoints.append(point)
        mosaicPath.addLine(to: point)
    }
    
    func drawPath() -> CGPath? {
        mosaicPath.cgPath
    }
}

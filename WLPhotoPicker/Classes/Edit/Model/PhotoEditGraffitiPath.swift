//
//  PhotoEditGraffitiPath.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

public struct PhotoEditGraffitiPath {
    
    var imageSize: CGSize = .zero
    var shapeSize: CGSize = .zero
    
    var pathLines: [PhotoEditGraffitiPathLine] = []
    
    var last: PhotoEditGraffitiPathLine? {
        pathLines.last
    }
    
    mutating func append(pathLine: PhotoEditGraffitiPathLine) {
        pathLines.append(pathLine)
    }
    
    mutating func removeLast() {
        if pathLines.count > 0 {
            pathLines.removeLast()
        }
    }
    
    func draw() -> UIImage? {
        if pathLines.isEmpty {
            return nil
        }
        let scale = imageSize.width / shapeSize.width
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1)
        defer {
            UIGraphicsEndImageContext()
        }
        
        for path in self.pathLines {
            let graffitiPath = UIBezierPath()
            graffitiPath.lineCapStyle = .round
            graffitiPath.lineJoinStyle = .round
            graffitiPath.lineWidth = path.lineWidth * scale
            graffitiPath.move(to: CGPoint(x: path.startPoint.x * scale, y: path.startPoint.y * scale))
            path.locations.forEach { point in
                graffitiPath.addLine(to: CGPoint(x: point.x * scale, y: point.y * scale))
            }
            path.graffitiColor.set()
            graffitiPath.stroke()
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

public class PhotoEditGraffitiPathLine {
    
    let startPoint: CGPoint
    let lineWidth: CGFloat
    let graffitiColor: UIColor
    
    var locations: [CGPoint] = []
    
    init(graffitiColor: UIColor, lineWidth: CGFloat, startPoint: CGPoint) {
        self.graffitiColor = graffitiColor
        self.lineWidth = lineWidth
        self.startPoint = startPoint
    }
    
    func addLine(to point: CGPoint) {
        locations.append(point)
    }
    
}

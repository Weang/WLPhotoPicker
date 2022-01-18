//
//  CoreTextHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

class CoreTextHelper {

    static func getLineRectsFrom(_ attributedString: NSAttributedString, containerWidth: CGFloat) -> [CGRect] {
        let path = CGMutablePath()
        path.addRect(CGRect(origin: .zero, size: CGSize(width: containerWidth, height: CGFloat(MAXFLOAT))))
        
        let ctFrameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let cfRange = CFRange(location: 0, length: attributedString.length)
        let ctFrame = CTFramesetterCreateFrame(ctFrameSetter, cfRange, path, nil)
        let ctLines = CTFrameGetLines(ctFrame)
        let lineCount = CFArrayGetCount(ctLines)
        guard lineCount > 0 else {
            return []
        }
        var rects: [CGRect] = []
        for i in 0..<lineCount {
            let ctLine = unsafeBitCast(CFArrayGetValueAtIndex(ctLines, i), to: CTLine.self)
            rects.append(CTLineGetBoundsWithOptions(ctLine, CTLineBoundsOptions()))
        }
        return rects
    }
    
}

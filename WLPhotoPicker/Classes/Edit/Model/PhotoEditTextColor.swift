//
//  PhotoEditTextColor.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

public class PhotoEditTextColor {

    let tintColor: UIColor
    let textColor: UIColor

    init(tintColor: UIColor, textColor: UIColor) {
        self.tintColor = tintColor
        self.textColor = textColor
    }
    
}

public extension PhotoEditTextColor {
    
    static var `default`: [PhotoEditTextColor]  {
        [PhotoEditTextColor(tintColor: #colorLiteral(red: 0.9450979829, green: 0.9450982213, blue: 0.9494037032, alpha: 1), textColor: .black),
         PhotoEditTextColor(tintColor: #colorLiteral(red: 0.1638098657, green: 0.1687904298, blue: 0.168703407, alpha: 1), textColor: .white),
         PhotoEditTextColor(tintColor: #colorLiteral(red: 0.9752930999, green: 0.3147607744, blue: 0.3190720677, alpha: 1), textColor: .white),
         PhotoEditTextColor(tintColor: #colorLiteral(red: 0.9968875051, green: 0.7632474303, blue: 0, alpha: 1), textColor: .white),
         PhotoEditTextColor(tintColor: #colorLiteral(red: 0.02922653779, green: 0.7524088621, blue: 0.375612855, alpha: 1), textColor: .white),
         PhotoEditTextColor(tintColor: #colorLiteral(red: 0.05218506604, green: 0.6807786822, blue: 0.9946766496, alpha: 1), textColor: .white),
         PhotoEditTextColor(tintColor: #colorLiteral(red: 0.3903390169, green: 0.4003461599, blue: 0.9338593483, alpha: 1), textColor: .white)]
    }
    
}

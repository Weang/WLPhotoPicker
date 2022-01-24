//
//  BundleHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/30.
//

import UIKit

fileprivate class _BundleClass { }

fileprivate let bundle = Bundle(for: _BundleClass.self)

class BundleHelper {
    
    static func imageNamed(_ name: String) -> UIImage? {
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
}

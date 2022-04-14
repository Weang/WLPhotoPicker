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
    
    static func localizedString(_ key: LocalizedKey, _ args: CVarArg...) -> String {
        if let text = WLPhotoUIConfig.default.localizedText[key] {
            return text
        }
        let bundlePath: String
        if let path = bundle.path(forResource: WLPhotoUIConfig.default.language.bundleName, ofType: "lproj") {
            bundlePath = path
        } else if let path = bundle.path(forResource: "en", ofType: "lproj") {
            bundlePath = path
        } else {
            return ""
        }
        guard let bundle = Bundle(path: bundlePath) else {
            return ""
        }
        let value = bundle.localizedString(forKey: key.rawValue, value: nil, table: nil)
        let text = Bundle.main.localizedString(forKey: key.rawValue, value: value, table: nil)
        return String(format: text, args)
    }
    
}

//
//  LanguageRegionCode.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/14.
//

import UIKit

class LanguageRegionCode {
    
    static func languageCodeWith(_ preferredLanguage: String) -> String {
        let splits = preferredLanguage.split(separator: "-").map { String($0) }
        switch splits.count {
        case 1, 2: return splits[0]
        case 3: return splits[0] + "-" + splits[1]
        default: return ""
        }
    }
    
}

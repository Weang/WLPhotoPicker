//
//  UIApplication+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit

extension UIApplication {
    
    func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    var appName: String? {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
}

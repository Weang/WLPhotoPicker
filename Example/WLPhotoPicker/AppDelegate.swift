//
//  AppDelegate.swift
//  WLPhotoPicker
//
//  Created by Weang on 01/18/2022.
//  Copyright (c) 2022 Weang. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        #if DEBUG
        UIApplication.shared.isIdleTimerDisabled = true
        #endif
        
        return true
    }
}


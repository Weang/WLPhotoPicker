//
//  ImageMemoryCache.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

// 图片缓存，用于存储选中的资源
private class ImageMemoryCache: NSCache<NSString, UIImage> {
    
    let lock = NSLock()
    let notificationName = UIApplication.didReceiveMemoryWarningNotification
    
    static let shared = ImageMemoryCache()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: notificationName, object: nil)
        
        totalCostLimit = 0
        countLimit = 0
    }
    
    func setImage(_ image: UIImage?, for key: String) {
        guard let image = image else {
            removeObject(forKey: key as NSString)
            return
        }
        setObject(image, forKey: key as NSString)
    }
    
    func removeImage(for key: String) {
        removeObject(forKey: key as NSString)
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        object(forKey: key as NSString)
    }
    
    @objc func didReceiveMemoryWarning() {
        removeAllObjects()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
}

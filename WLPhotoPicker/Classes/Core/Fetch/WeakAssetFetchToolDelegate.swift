//
//  WeakAssetFetchToolDelegate.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit

final class WeakAssetFetchToolDelegate {
    
    private(set) weak var value: AssetFetchToolDelegate?

    init(value: AssetFetchToolDelegate?) {
        self.value = value
    }
}

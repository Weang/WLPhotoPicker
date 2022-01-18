//
//  PhotoEditFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/9.
//

import UIKit

public protocol PhotoEditFilterProvider {
    var name: String { get }
    func filterImage(_ image: UIImage?) -> UIImage?
}

public class PhotoEditDefaultFilter {
    
    static public var all: [PhotoEditFilterProvider] {
        [original, fade, clarendon]
    }
    
    static public let original: PhotoEditFilterProvider = PhotoEditOriginalFilter()
    static public let fade: PhotoEditFilterProvider = PhotoEditFadeFilter()
    static public let clarendon: PhotoEditFilterProvider = PhotoEditClarendonFilter()
    
}

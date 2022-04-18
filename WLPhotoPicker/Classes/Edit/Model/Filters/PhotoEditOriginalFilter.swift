//
//  PhotoEditOriginalFilter.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/10.
//

import UIKit

public class PhotoEditOriginalFilter: PhotoEditFilterProvider {
    
    public var name: String {
        "Original"
    }
    
    public var filter: FilterProviderClosure? {
        return nil
    }
    
}

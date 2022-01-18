//
//  AssetPickerResult.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit
import AVFoundation

public struct AssetPickerResult {
    public let asset: AssetModel
    public var image: UIImage? = nil
    public var playerItem: AVPlayerItem? = nil
    public var fileURL: URL? = nil
}

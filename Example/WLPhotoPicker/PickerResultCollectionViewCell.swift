//
//  PickerResultCollectionViewCell.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import AVFoundation

class PickerResultCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let detailInfoView = UIView()
    let detailInfoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        detailInfoView.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        contentView.addSubview(detailInfoView)
        detailInfoView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        detailInfoLabel.textColor = .white
        detailInfoLabel.numberOfLines = 0
        detailInfoLabel.font = UIFont.systemFont(ofSize: 12)
        detailInfoView.addSubview(detailInfoLabel)
        detailInfoLabel.snp.makeConstraints { make in
            make.top.left.equalTo(4)
            make.bottom.right.equalTo(-4)
        }
    }
    
    func setResult(_ result: PhotoPickerResult) {
        imageView.image = result.photo
        var info = ""
        
        switch result.result {
        case .photo(let photoResult):
            info += "Type: Photo"
            info += "\nSize: (\(photoResult.photo.size.width), \(photoResult.photo.size.height))"
            if let photoURL = photoResult.photoURL {
                let fileSize = fileSizeAtURL(photoURL)
                info += "\nFileSize: \(fileSize)"
            }
        case .livePhoto(let livePhotoResult):
            info += "Type: LivePhoto"
            info += "\nSize: (\(livePhotoResult.photo.size.width), \(livePhotoResult.photo.size.height))"
            if let videoURL = livePhotoResult.videoURL {
                let fileSize = fileSizeAtURL(videoURL)
                info += "\nVideo FileSize: \(fileSize)"
            }
        case .video(let videoResult):
            let playerItem = videoResult.playerItem
            info += "Type: Video"
            info += String(format: "\nDuration: %.0fs", playerItem.asset.duration.seconds)
            
            if let videoURL = videoResult.videoURL {
                let playerItem = AVPlayerItem(asset: AVAsset(url: videoURL))
                if let videoTrack = playerItem.asset.tracks(withMediaType: .video).first {
                    info += "\nSize: (\(videoTrack.naturalSize.width), \(videoTrack.naturalSize.height))"
                    info += String(format: "\nFrameRate: %.0f", videoTrack.nominalFrameRate)
                }
                let fileSize = fileSizeAtURL(videoURL)
                info += "\nFileSize: \(fileSize)"
            } else if let videoTrack = playerItem.asset.tracks(withMediaType: .video).first {
                info += "\nSize: (\(videoTrack.naturalSize.width), \(videoTrack.naturalSize.height))"
                info += String(format: "\nFrameRate: %.0f", videoTrack.nominalFrameRate)
            }
        }
        
        detailInfoLabel.text = info
    }
    
    func fileSizeAtURL(_ url: URL) -> String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.relativePath) else {
            return ""
        }
        let dict = attributes as NSDictionary
        let size = Double(dict.fileSize())
        if size < 1000 * 1000 {
            return String.init(format: "%.0f KB",  size / 1000)
        } else if size < 1000 * 1000 * 1000 {
            return String.init(format: "%.0f MB",  size / (1000 * 1000))
        } else {
            return String.init(format: "%.0f GB",  size / (1000 * 1000 * 1000))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

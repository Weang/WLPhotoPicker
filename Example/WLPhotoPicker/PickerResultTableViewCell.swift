//
//  PickerResultTableViewCell.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/1/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import WLPhotoPicker
import AVFoundation

class PickerResultTableViewCell: UITableViewCell {

    let assetImageView = UIImageView()
    let describeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        assetImageView.contentMode = .scaleAspectFit
        assetImageView.clipsToBounds = true
        contentView.addSubview(assetImageView)
        assetImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(assetImageView.snp.height).multipliedBy(1)
        }
        
        describeLabel.numberOfLines = 0
        contentView.addSubview(describeLabel)
        describeLabel.snp.makeConstraints { make in
            make.left.equalTo(assetImageView.snp.right).offset(16)
            make.right.equalTo(-16)
            make.top.equalTo(16)
        }
    }
    
    func bind(_ model: AssetPickerResult) {
        assetImageView.image = model.photo

        if let image = model.photo {
            assetImageView.snp.remakeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalTo(assetImageView.snp.height).multipliedBy(image.size.width / image.size.height)
            }
        }

        if case .video(let result) = model.result {
            var playerItem: AVPlayerItem = result.playerItem
            if let fileURL = result.videoURL {
                playerItem = AVPlayerItem(asset: AVAsset(url: fileURL))
            }
            var text = String(format: "时长：%.0fs", playerItem.asset.duration.seconds)
            text += "\n宽高： \(playerItem.asset.tracks(withMediaType: .video).first?.naturalSize ?? .zero)"
            text += String(format: "\n帧率：%.0f", playerItem.asset.tracks(withMediaType: .video).first?.nominalFrameRate ?? 0)
            if let path = result.videoURL?.relativePath,
               let attr = try? FileManager.default.attributesOfItem(atPath: path) as NSDictionary {
                let fileSize = Double(attr.fileSize())
                text += "\n导出文件大小： \(formateSize(size: fileSize))"
            }
            describeLabel.text = text
        } else {
            describeLabel.text = "宽高： \(model.photo?.size ?? .zero)"
        }
    }
    
    func formateSize(size: Double) -> String {
        if size < 1000 * 1000 {
            return String.init(format: "%.1f K",  size / 1000)
        } else if size < 1000 * 1000 * 1000 {
            return String.init(format: "%.1f M",  size / (1000 * 1000))
        } else {
            return String.init(format: "%.1f G",  size / (1000 * 1000 * 1000))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

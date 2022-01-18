//
//  AssetPreviewGIFCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit

class AssetPreviewGIFCell: AssetPreviewCell {
    
    override func requestImage(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        assetImageView.image = thumbnail
        
        let options = AssetFetchOptions()
        options.progressHandler = defaultProgressHandle
        
        assetRequest = AssetFetchTool.requestGIF(for: model.asset, options: options, completion: { [weak self] result, _ in
            self?.setProgress(1)
            switch result {
            case .success(let respose):
                self?.assetImageView.image = respose.image
            case .failure: break
            }
        })
    }
    
    override func beginPanGes() {
        super.beginPanGes()
    }
    
    override func finishPanGes(dismiss: Bool) {
        super.finishPanGes(dismiss: dismiss)
        if !dismiss {
            assetImageView.startAnimating()
        }
    }
    
}

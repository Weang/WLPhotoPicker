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
        
        activityIndicator.startAnimating()
        
        assetRequest = AssetFetchTool.requestGIF(for: model.asset, options: options, completion: { [weak self] result, _ in
            self?.activityIndicator.stopAnimating()
            if case .success(let response) = result {
                self?.assetImageView.image = response.image
            }
        })
    }
    
}

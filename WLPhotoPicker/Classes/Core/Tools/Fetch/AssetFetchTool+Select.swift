//
//  AssetFetchTool+Select.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/27.
//

import UIKit

fileprivate var selectedAssetRequest: [String: AssetFetchRequest] = [:]

extension AssetFetchTool {
    
    var isUptoLimit: Bool {
        selectedAssets.count >= pickerConfig.selectCountLimit
    }
    
    public func selectedAsset(asset: AssetModel, delegateEvent: Bool = true) {
        guard let albumModel = self.albumModel, config.pickerConfig.allowSelectMultiPhoto else {
            return
        }
        if !asset.isSelected && isUptoLimit {
            return
        }
        if !asset.isSelected {
            asset.selectedIndex = selectedAssets.count + 1
            asset.isSelected = true
            selectedAssets.append(asset)
            if isUptoLimit {
                albumModel.assets.filter { asset in
                    !selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier })
                }.forEach {
                    $0.isEnabled = false
                }
            }
            fetchSelectedAsset(asset: asset, delegateEvent: delegateEvent)
        }
        if delegateEvent {
            delegateEventsWith(asset: asset)
        }
    }
    
    public func deselectedAsset(asset: AssetModel, delegateEvent: Bool = true) {
        guard let albumModel = self.albumModel else {
            return
        }
        guard selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) else {
            return
        }
        asset.isSelected = false
        selectedAssets.removeAll(where: {
            $0.localIdentifier == asset.localIdentifier
        })
        selectedAssets = selectedAssets.sorted(by: { $0.selectedIndex < $1.selectedIndex })
        selectedAssets.enumerated().forEach { index, assetModel in
            assetModel.selectedIndex = index + 1
        }
        albumModel.assets.forEach {
            $0.isEnabled = true
        }
        cancelFetchSelectedAsset(asset: asset)
        if delegateEvent {
            delegateEventsWith(asset: asset)
        }
    }
    
    func delegateEventsWith(asset: AssetModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegates.forEach {
                $0.value?.assetFetchTool(self, updateSelectedStatus: asset)
            }
        }
    }
    
    func fetchSelectedAsset(asset: AssetModel, delegateEvent: Bool) {
        let options = AssetFetchOptions()
        options.imageDeliveryMode = .highQualityFormat
        options.sizeOption = .specify(pickerConfig.maximumPreviewSize)
        
        let request = AssetFetchTool.requestPhoto(for: asset.asset, options: options) { [weak self] result, _ in
            if case .success(let response) = result {
                asset.previewImage = response.image
                guard let self = self, delegateEvent else {
                    return
                }
                self.delegates.forEach {
                    $0.value?.assetFetchTool(self, finishFetchSelectedAsset: asset)
                }
            }
        }
        selectedAssetRequest[asset.localIdentifier] = request
    }
    
    func cancelFetchSelectedAsset(asset: AssetModel) {
        selectedAssetRequest[asset.localIdentifier]?.cancel()
        selectedAssetRequest.removeValue(forKey: asset.localIdentifier)
        asset.previewImage = nil
    }
}

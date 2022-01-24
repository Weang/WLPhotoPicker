//
//  AssetPreviewThumbnailCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/23.
//

import UIKit

class AssetPreviewThumbnailCell: UICollectionViewCell {
    
    private let assetImageView = UIImageView()
    private let descriptionView = AssetDescriptionView()
    private let highlightCover = UIView()
    
    private var assetRequest: AssetFetchRequest?
    
    override var isSelected: Bool {
        didSet {
            highlightCover.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        assetImageView.contentMode = .scaleAspectFill
        assetImageView.clipsToBounds = true
        contentView.addSubview(assetImageView)
        assetImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        highlightCover.isHidden = true
        highlightCover.layer.borderWidth = 4
        highlightCover.layer.borderColor = WLPhotoUIConfig.default.color.primaryColor.cgColor
        contentView.addSubview(highlightCover)
        highlightCover.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(_ model: AssetModel) {
        descriptionView.bindPreview(model)
        cancelCurrentRequest()
        
        if let displayingImage = model.displayingImage {
            assetImageView.image = displayingImage
            return
        }
        
        let options = AssetFetchOptions()
        let targetSize = 64 * UIScreen.main.scale
        options.sizeOption = .specify(targetSize)
        assetRequest = AssetFetchTool.requestImage(for: model.asset, options: options, completion: { [weak self] result, requestId in
            switch result {
            case let .success(respose):
                if self?.assetRequest?.containsRequestId(requestId) ?? false {
                    self?.assetImageView.image = respose.image
                }
            case .failure: break
            }
        })
    }
    
    private func cancelCurrentRequest() {
        assetRequest?.cancel()
        assetRequest = nil
        assetImageView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelCurrentRequest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

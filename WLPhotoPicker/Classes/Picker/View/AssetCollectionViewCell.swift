//
//  AssetCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

protocol AssetCollectionViewCellDelegate: AnyObject {
    func cell(_ cell: AssetCollectionViewCell, didChangeSelectedStatus selected: Bool)
}

class AssetCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: AssetCollectionViewCellDelegate?
    
    let assetImageView = UIImageView()
    private let selectedButton = CircleSelectedButton()
    private let selectedCover = UIView()
    private let disabledCover = UIView()
    private let descriptionView = AssetDescriptionView()
    
    private var assetRequest: AssetFetchRequest?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        assetImageView.contentMode = .scaleAspectFill
        assetImageView.clipsToBounds = true
        contentView.addSubview(assetImageView)
        assetImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedCover.isHidden = true
        selectedCover.backgroundColor = UIColor(white: 0, alpha: 0.4)
        contentView.addSubview(selectedCover)
        selectedCover.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedButton.isSelected = false
        selectedButton.addTarget(self, action: #selector(selectButtonClick), for: .touchUpInside)
        contentView.addSubview(selectedButton)
        selectedButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.width.equalTo(40)
        }
        
        descriptionView.isHidden = true
        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(24)
        }
        
        disabledCover.isUserInteractionEnabled = false
        disabledCover.backgroundColor = UIColor(white: 1, alpha: 0.5)
        disabledCover.isHidden = true
        contentView.addSubview(disabledCover)
        disabledCover.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(_ model: AssetModel, pickerConfig: PickerConfig) {
        selectedButton.isHidden = !pickerConfig.allowSelectMultiPhoto
        update(model, animated: false)
        
        cancelCurrentRequest()
        
        if let displayingImage = model.displayingImage {
            assetImageView.image = displayingImage
        } else {
            let options = AssetFetchOptions()
            let targetSize = pickerConfig.photoCollectionViewItemSize.width * UIScreen.main.scale
            options.sizeOption = .specify(targetSize)
            assetRequest = AssetFetchTool.requestImage(for: model.asset, options: options, completion: { [weak self] result, requestId in
                if case .success(let respose) = result {
                    if respose.isDegraded || (self?.assetRequest?.containsRequestId(requestId) ?? false) {
                        self?.assetImageView.image = respose.image
                    }
                }
            })
        }
    }
    
    func update(_ model: AssetModel, animated: Bool) {
        descriptionView.bind(model)
        selectedCover.isHidden = !model.isSelected
        disabledCover.isHidden = model.isEnabled
        selectedButton.set(isSelected: model.isSelected, selectedIndex: model.selectedIndex, animated: animated)
    }
    
    @objc private func selectButtonClick() {
        delegate?.cell(self, didChangeSelectedStatus: !selectedButton.isSelected)
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

//
//  AssetPreviewToolBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/24.
//

import UIKit

public protocol AssetPreviewToolBarDelegate: AnyObject {
    func toolBar(_ toolBar: AssetPreviewToolBar, didSelectAsset asset: AssetModel)
    func toolBarDidClickEditButton(_ toolBar: AssetPreviewToolBar)
    func toolBarDidClickOriginButton(_ toolBar: AssetPreviewToolBar, isOrigin: Bool)
    func toolBarDidClickDoneButton(_ toolBar: AssetPreviewToolBar)
}

public class AssetPreviewToolBar: VisualEffectView {
    
    private let previewThumbnailItemSize: CGSize = CGSize(width: 64, height: 64)
    private let previewThumbnailColumnSpace: CGFloat = 16
    private let previewThumbnailHeight: CGFloat = 96
    private let toolBarHeight: CGFloat = 54
    
    public var isOrigin: Bool = false {
        didSet {
            originButton.isSelected = isOrigin
        }
    }
    
    private let thumbnailContentView = UIView()
    private var collectionView: UICollectionView!
    
    private let toolBarContentView = UIStackView()
    private let editButton = UIButton()
    private let originButton = UIButton()
    private let doneButton = UIButton()
    
    private var selectedAssets: [AssetModel] = []
    private let pickerConfig: PickerConfig
    
    public weak var delegate: AssetPreviewToolBarDelegate?
    
    public init(pickerConfig: PickerConfig) {
        self.pickerConfig = pickerConfig
        super.init(frame: .zero)
        
        addSubview(thumbnailContentView)
        thumbnailContentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(previewThumbnailHeight)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = previewThumbnailColumnSpace
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = previewThumbnailItemSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: previewThumbnailColumnSpace, bottom: 0, right: previewThumbnailColumnSpace)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(AssetPreviewThumbnailCell.self)
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        thumbnailContentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(previewThumbnailItemSize.height)
        }
        
        toolBarContentView.axis = .horizontal
        toolBarContentView.distribution = .equalSpacing
        toolBarContentView.alignment = .center
        addSubview(toolBarContentView)
        toolBarContentView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(toolBarHeight)
            make.bottom.equalTo(-keyWindowSafeAreaInsets.bottom)
        }
        
        if pickerConfig.allowEditPhoto {
            editButton.setTitleColor(WLPhotoPickerUIConfig.default.textColor, for: .normal)
            editButton.setTitle("编辑", for: .normal)
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            editButton.addTarget(self, action: #selector(editButtonClick), for: .touchUpInside)
            toolBarContentView.addArrangedSubview(editButton)
        }
        
        if pickerConfig.allowSelectOriginal {
            originButton.setImage(BundleHelper.imageNamed("select_normal"), for: .normal)
            originButton.setImage(BundleHelper.imageNamed("select_fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
            originButton.tintColor = WLPhotoPickerUIConfig.default.themeColor
            originButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            originButton.setTitleColor(WLPhotoPickerUIConfig.default.textColor, for: .normal)
            originButton.setTitle("原图", for: .normal)
            originButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            originButton.addTarget(self, action: #selector(originButtonClick), for: .touchUpInside)
            toolBarContentView.addArrangedSubview(originButton)
        }
        if !pickerConfig.allowEditPhoto && !pickerConfig.allowSelectOriginal {
            toolBarContentView.addArrangedSubview(UIView())
        }
        doneButton.layer.cornerRadius = 4
        doneButton.layer.masksToBounds = true
        doneButton.setBackgroundImage(UIImage.imageWithColor(WLPhotoPickerUIConfig.default.themeColor), for: .normal)
        doneButton.setTitle("完成", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        toolBarContentView.addArrangedSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(56)
        }
    }
    
    @objc func editButtonClick() {
        delegate?.toolBarDidClickEditButton(self)
    }
    
    @objc func originButtonClick() {
        originButton.isSelected.toggle()
        delegate?.toolBarDidClickOriginButton(self, isOrigin: originButton.isSelected)
    }
    
    @objc func doneButtonClick() {
        delegate?.toolBarDidClickDoneButton(self)
    }
    
    public func setSelectedAssets(_ assetList: [AssetModel]) {
        selectedAssets = assetList
        collectionView.reloadData()
        invalidateIntrinsicContentSize()
        thumbnailContentView.isHidden = selectedAssets.count == 0
    }
    
    public func setCurrentAsset(_ asset: AssetModel?, animated: Bool) {
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems ?? []
        if let asset = asset,
           let shouldSelectIndex = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            let indxPath = IndexPath(item: shouldSelectIndex, section: 0)
            if !selectedIndexPaths.contains(indxPath) {
                collectionView.selectItem(at: indxPath, animated: animated, scrollPosition: .centeredHorizontally)
            }
        } else {
            selectedIndexPaths.forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }
        }
        if let asset = asset {
            editButton.alpha = asset.mediaType == .photo ? 1 : 0
            originButton.alpha = asset.mediaType == .photo || (asset.mediaType == .video && pickerConfig.videoExportOriginal) ? 1 : 0
        }
    }
    
    func updateAsset(_ asset: AssetModel) {
        if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            if asset.isSelected {
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                setCurrentAsset(asset, animated: true)
            } else {
                selectedAssets.remove(at: index)
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                setCurrentAsset(nil, animated: true)
            }
        } else {
            selectedAssets.append(asset)
            collectionView.insertItems(at: [IndexPath(item: selectedAssets.count - 1, section: 0)])
            setCurrentAsset(asset, animated: true)
        }
        invalidateIntrinsicContentSize()
        thumbnailContentView.isHidden = selectedAssets.count == 0
    }
    
    public override var intrinsicContentSize: CGSize {
        var height = toolBarHeight + keyWindowSafeAreaInsets.bottom
        if selectedAssets.count > 0 {
            height += previewThumbnailHeight
        }
        return CGSize(width: UIScreen.width, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AssetPreviewToolBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(AssetPreviewThumbnailCell.self, for: indexPath)
        cell.bind(selectedAssets[indexPath.item])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.toolBar(self, didSelectAsset: selectedAssets[indexPath.item])
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            return false
        }
        return true
    }
}

//
//  PhotoEditBottomToolBar.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

protocol PhotoEditBottomToolBarDelegate: AnyObject {
    
    // 类型选择
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectItemType itemType: PhotoEditItemType?)
    
    // 涂鸦
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectGraffitiColor graffitiColor: UIColor)
    func bottomToolBarDidClickGraffitiUndoButton(_ bottomToolBar: PhotoEditBottomToolBar)
    
    // 马赛克
    func bottomToolBarDidClickMosaicUndoButton(_ bottomToolBar: PhotoEditBottomToolBar)
    
    // 图片滤镜
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectFilter filter: PhotoEditFilterProvider, index: Int)
    
    // 图片调整
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectAdjustMode adjustMode: PhotoEditAdjustMode)
    
    // 点击确定
    func bottomToolBarDidClickDoneButton(_ bottomToolBar: PhotoEditBottomToolBar)
}

class PhotoEditBottomToolBar: UIView {
    
    weak var delegate: PhotoEditBottomToolBarDelegate?
    
    private let editBottomToolBarHeight: CGFloat = 154
    private let itemsContentViewHeight: CGFloat = 72
    private let graffitiContentViewHeight: CGFloat = 42
    private let mosaicContentViewHeight: CGFloat = 42
    private let filtersContentViewHeight: CGFloat = 82
    private let adjustContentViewHeight: CGFloat = 52
    
    private let contentView = UIView()
    private let doneButton = UIButton()
    private var editItemCollectionView: UICollectionView!
    private let gradientLayer = CAGradientLayer()
    
    private lazy var graffitiContentView: PhotoEditGraffitiColorsView = {
        return PhotoEditGraffitiColorsView(photoEditConfig: photoEditConfig)
    }()
    
    private lazy var mosaicContentView: UIView = {
        return UIView()
    }()
    
    private lazy var filtersContentView: PhotoEditFiltersView = {
        return PhotoEditFiltersView(photo: photo, photoEditConfig: photoEditConfig)
    }()
    
    private lazy var adjustContentView: PhotoEditAdjustView = {
        return PhotoEditAdjustView(photoEditConfig: photoEditConfig)
    }()
    
    private let photo: UIImage?
    private let photoEditConfig: PhotoEditConfig
    private var currentItemType: PhotoEditItemType?
    var selectedFilterIndex: Int = 0
    
    init(photo: UIImage?, photoEditConfig: PhotoEditConfig) {
        self.photo = photo
        self.photoEditConfig = photoEditConfig
        
        super.init(frame: .zero)
        
        setupContentView()
    }
    
    private func setupContentView() {
        backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        
        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-keyWindowSafeAreaInsets.bottom)
            make.height.equalTo(itemsContentViewHeight)
        }
        
        doneButton.layer.cornerRadius = 6
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        doneButton.setBackgroundImage(UIImage.imageWithColor(WLPhotoUIConfig.default.color.primaryColor), for: .normal)
        doneButton.setTitle(BundleHelper.localizedString(.Confirm), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(60)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        editItemCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        editItemCollectionView.backgroundColor = .clear
        editItemCollectionView.delegate = self
        editItemCollectionView.dataSource = self
        editItemCollectionView.showsHorizontalScrollIndicator = false
        editItemCollectionView.alwaysBounceHorizontal = true
        editItemCollectionView.register(PhotoEditItemCollectionViewCell.self)
        contentView.addSubview(editItemCollectionView)
        editItemCollectionView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.right.equalTo(doneButton.snp.left).offset(-10)
        }
    }
    
    private func setupGraffitiView() {
        graffitiContentView.delegate = self
        graffitiContentView.isHidden = true
        addSubview(graffitiContentView)
        graffitiContentView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(graffitiContentViewHeight)
        }
    }
    
    private func setupMosaicView() {
        mosaicContentView.isHidden = true
        addSubview(mosaicContentView)
        mosaicContentView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(mosaicContentViewHeight)
        }
        
        let undoButton = UIButton()
        undoButton.tintColor = .white
        undoButton.addTarget(self, action: #selector(undoButtonClick), for: .touchUpInside)
        undoButton.setImage(BundleHelper.imageNamed("undo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        mosaicContentView.addSubview(undoButton)
        undoButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupFiltersView() {
        filtersContentView.delegate = self
        filtersContentView.isHidden = true
        filtersContentView.selectFilterIndex(selectedFilterIndex)
        addSubview(filtersContentView)
        filtersContentView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(filtersContentViewHeight)
        }
    }
    
    private func setupAdjustView() {
        adjustContentView.delegate = self
        adjustContentView.isHidden = true
        addSubview(adjustContentView)
        adjustContentView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(adjustContentViewHeight)
        }
    }
    
    private func selectEditItem(_ itemType: PhotoEditItemType?) {
        delegate?.bottomToolBar(self, didSelectItemType: itemType)
        guard itemType?.canBeHighlight ?? true else {
            return
        }
        currentItemType = itemType
        invalidateIntrinsicContentSize()
        
        if itemType == .graffiti {
            setupGraffitiView()
            if let graffitiColor = graffitiContentView.currentColor {
                delegate?.bottomToolBar(self, didSelectGraffitiColor: graffitiColor)
            }
        }
        
        if itemType == .mosaic {
            setupMosaicView()
        }
        
        if itemType == .filter {
            setupFiltersView()
        }
        
        if itemType == .adjust {
            setupAdjustView()
            if let adjustMode = adjustContentView.currentAdjustMode {
                delegate?.bottomToolBar(self, didSelectAdjustMode: adjustMode)
            }
        }
        
        graffitiContentView.isHidden = itemType != .graffiti
        mosaicContentView.isHidden = itemType != .mosaic
        filtersContentView.isHidden = itemType != .filter
        adjustContentView.isHidden = itemType != .adjust
    }
    
    @objc private func doneButtonClick() {
        delegate?.bottomToolBarDidClickDoneButton(self)
    }
    
    @objc private func undoButtonClick() {
        delegate?.bottomToolBarDidClickMosaicUndoButton(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor(white: 0, alpha: 0).cgColor,
                                UIColor(white: 0, alpha: 0.4).cgColor]
        gradientLayer.removeAllAnimations()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.width, height: editBottomToolBarHeight + keyWindowSafeAreaInsets.bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditBottomToolBar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoEditConfig.photoEditItemTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditItemCollectionViewCell.self, for: indexPath)
        cell.bind(photoEditConfig.photoEditItemTypes[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let canBeHighlight = photoEditConfig.photoEditItemTypes[indexPath.item].canBeHighlight
        let isCurrentSelected = collectionView.indexPathsForSelectedItems?.first == indexPath
        if canBeHighlight && !isCurrentSelected {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if isCurrentSelected && canBeHighlight {
            collectionView.deselectItem(at: indexPath, animated: false)
            selectEditItem(nil)
            return false
        } else {
            selectEditItem(photoEditConfig.photoEditItemTypes[indexPath.item])
        }
        return canBeHighlight
    }
    
}

extension PhotoEditBottomToolBar: PhotoEditGraffitiColorsViewDelegate {
    
    func graffitiColorsViewDidClickUndoButton(_ graffitiColorsView: PhotoEditGraffitiColorsView) {
        delegate?.bottomToolBarDidClickGraffitiUndoButton(self)
    }
    
    func graffitiColorsView(_ graffitiColorsView: PhotoEditGraffitiColorsView, didSelectColor color: UIColor) {
        delegate?.bottomToolBar(self, didSelectGraffitiColor: color)
    }
    
}

extension PhotoEditBottomToolBar: PhotoEditAdjustViewDelegate {
    
    func adjustView(_ adjustView: PhotoEditAdjustView, didSelectAdjustMode: PhotoEditAdjustMode) {
        delegate?.bottomToolBar(self, didSelectAdjustMode: didSelectAdjustMode)
    }
    
}

extension PhotoEditBottomToolBar: PhotoEditFiltersViewDelegate {
    
    func filtersView(_ filtersView: PhotoEditFiltersView, didSelectFilter filter: PhotoEditFilterProvider, index: Int) {
        delegate?.bottomToolBar(self, didSelectFilter: filter, index: index)
    }
    
}

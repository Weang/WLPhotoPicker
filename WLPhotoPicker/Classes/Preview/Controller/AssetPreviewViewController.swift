//
//  AssetPreviewViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/13.
//

import UIKit

protocol AssetPreviewViewControllerAnimateDataSource: AnyObject {
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, sourceViewFor index: Int) -> UIImageView?
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, assetSizeFor index: Int) -> CGSize
}

protocol AssetPreviewViewControllerDelegate: AnyObject {
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didScrollTo indexPath: IndexPath)
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didClickDoneWithAssets assets: [AssetModel])
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didChangeIsOriginal isOriginal: Bool)
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didFinishEditImageAt indexPath: IndexPath)
}

class AssetPreviewViewController: UIViewController {
    
    private let itemSpacing: CGFloat = 28
    
    let topToolBar: AssetPreviewNavigationBar
    let bottomToolBar: AssetPreviewToolBar
    let animateImageView = UIImageView()
    let collectionViewLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    
    weak var animateDataSource: AssetPreviewViewControllerAnimateDataSource?
    weak var deleagte: AssetPreviewViewControllerDelegate?
    
    var currentIndex: Int?
    private var showToolBar: Bool = true
    private var previewCellIsDragging: Bool = false
    
    var toolbars: [UIView] {
        [topToolBar, bottomToolBar]
    }
    
    let assetFetchTool: AssetFetchTool
    private let config: WLPhotoConfig
    
    init(config: WLPhotoConfig, assetFetchTool: AssetFetchTool) {
        self.config = config
        self.assetFetchTool = assetFetchTool
        self.topToolBar = AssetPreviewNavigationBar(pickerConfig: config.pickerConfig)
        self.bottomToolBar = AssetPreviewToolBar(pickerConfig: config.pickerConfig)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true
        assetFetchTool.addDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        
        collectionViewLayout.itemSize = UIScreen.size
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: itemSpacing)
        collectionViewLayout.minimumLineSpacing = itemSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AssetPreviewCell.self)
        collectionView.register(AssetPreviewPhotoCell.self)
        collectionView.register(AssetPreviewVideoCell.self)
        collectionView.register(AssetPreviewGIFCell.self)
        collectionView.register(AssetPreviewLivePhotoCell.self)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(collectionViewLayout.minimumLineSpacing)
        }
        
        animateImageView.contentMode = .scaleAspectFill
        animateImageView.clipsToBounds = true
        view.addSubview(animateImageView)
        
        topToolBar.delegate = self
        view.addSubview(topToolBar)
        topToolBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        bottomToolBar.delegate = self
        bottomToolBar.isOriginal = assetFetchTool.isOriginal
        bottomToolBar.setSelectedAssets(assetFetchTool.selectedAssets)
        view.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func changeToolBarStatus() {
        showToolBar.toggle()
        view.backgroundColor = showToolBar ? WLPhotoUIConfig.default.color.previewBackground : .black
        toolbars.forEach{
            $0.alpha = showToolBar ? 1 : 0
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func updateToolBarsAt(_ index: Int, animated: Bool = true) {
        guard let albumModel = assetFetchTool.albumModel else {
            return
        }
        let assetModel = albumModel.assets[index]
        topToolBar.setCircleButton(isSelected: assetModel.isSelected, selectedIndex: assetModel.selectedIndex, animated: false)
        bottomToolBar.setCurrentAsset(assetModel, animated: animated)
    }
    
    private func openEditViewController(_ assetModel: AssetModel) {
        let vc = PhotoEditViewController(assetModel: assetModel,
                                         photoEditConfig: config.photoEditConfig)
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let currentIndex = self.currentIndex else {
            return
        }
        let offsetX = CGFloat(currentIndex) * (UIScreen.width + itemSpacing)
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        updateToolBarsAt(currentIndex, animated: false)
        self.currentIndex = nil
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .statusBarStyle(style: WLPhotoUIConfig.default.color.userInterfaceStyle)
    }
    
    override var prefersStatusBarHidden: Bool {
        return !showToolBar && (showToolBar || !previewCellIsDragging)
    }
    
    deinit {
        assetFetchTool.removeDeleagte(self)
    }
    
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension AssetPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetFetchTool.albumModel?.assets.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let albumModel = assetFetchTool.albumModel else {
            return collectionView.dequeueReusableCell(AssetPreviewCell.self, for: indexPath)
        }
        let assetModel = albumModel.assets[indexPath.item]
        let cell: AssetPreviewCell
        switch assetModel.mediaType {
        case .photo:
            cell = collectionView.dequeueReusableCell(AssetPreviewPhotoCell.self, for: indexPath)
        case .video:
            cell = collectionView.dequeueReusableCell(AssetPreviewVideoCell.self, for: indexPath)
        case .GIF:
            cell = collectionView.dequeueReusableCell(AssetPreviewGIFCell.self, for: indexPath)
        case .livePhoto:
            cell = collectionView.dequeueReusableCell(AssetPreviewLivePhotoCell.self, for: indexPath)
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetPreviewCell,
              let albumModel = assetFetchTool.albumModel else {
                  return
              }
        cell.isShowToolBar = showToolBar
        let thumbnail = animateDataSource?.imageBrowser(self, sourceViewFor: indexPath.item)?.image
        cell.setAsset(albumModel.assets[indexPath.item], thumbnail: thumbnail, pickerConfig: config.pickerConfig)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetIndex = max(Int(round(scrollView.contentOffset.x / scrollView.width)), 0)
        updateToolBarsAt(offsetIndex)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionView.visibleCells.compactMap {
            $0 as? AssetPreviewCell
        }.forEach {
            $0.cellDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetIndex = max(Int(round(scrollView.contentOffset.x / scrollView.width)), 0)
        deleagte?.imageBrowser(self, didScrollTo: IndexPath(item: offsetIndex, section: 0))
    }
}

// MARK: AssetFetchToolDelegate
extension AssetPreviewViewController: AssetFetchToolDelegate {
    
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateSelectedStatus assetModel: AssetModel) {
        topToolBar.setCircleButton(isSelected: assetModel.isSelected, selectedIndex: assetModel.selectedIndex, animated: true)
        bottomToolBar.updateAsset(assetModel)
    }
    
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateAlbum albumModel: AlbumModel, insertedItems: IndexSet, removedItems: IndexSet, changedItems: IndexSet) {
        collectionView.reloadData()
        collectionView.contentOffset = collectionView.contentOffset
        bottomToolBar.setSelectedAssets(assetFetchTool.selectedAssets)
        if let selectedAsset = assetFetchTool.selectedAssets.last,
           let index = assetFetchTool.albumModel?.assets.firstIndex(where: { $0.localIdentifier == selectedAsset.localIdentifier }) {
            updateToolBarsAt(index)
        }
    }
}

extension AssetPreviewViewController: AssetPreviewCellDelegate {
    
    func previewCellSingleTap(_ previewCell: AssetPreviewCell) {
        changeToolBarStatus()
    }
    
    func previewCellSingleTap(_ previewCell: AssetPreviewCell, shouldShowToolbar isShow: Bool) {
        showToolBar = !isShow
        changeToolBarStatus()
    }
    
    func previewCellSingleTapDidBeginPan(_ previewCell: AssetPreviewCell) {
        previewCellIsDragging = true
        setNeedsStatusBarAppearanceUpdate()
        guard showToolBar else {
            return
        }
        UIView.animate(withDuration: 0.1) {
            self.toolbars.forEach {
                $0.alpha = 0
            }
        }
    }
    
    func previewCellSingleTap(_ previewCell: AssetPreviewCell, didPanScale scale: CGFloat) {
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(scale)
    }
    
    func previewCellSingleTap(_ previewCell: AssetPreviewCell, didFinishPanDismiss dismiss: Bool) {
        if dismiss {
            self.dismiss(animated: true, completion: nil)
            return
        }
        previewCellIsDragging = false
        setNeedsStatusBarAppearanceUpdate()
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(1)
        if showToolBar {
            toolbars.forEach {
                $0.alpha = 1
            }
        }
    }
    
}

extension AssetPreviewViewController: AssetPreviewNavigationBarDelegate {
    
    func navigationBarDidClickCancelButton(_ navigationBar: AssetPreviewNavigationBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func navigationBar(_ navigationBar: AssetPreviewNavigationBar, didClickSelectButton isSelected: Bool) {
        guard let albumModel = assetFetchTool.albumModel else {
            return
        }
        let index = Int(collectionView.contentOffset.x / collectionView.width)
        let asset = albumModel.assets[index]
        
        if isSelected {
            assetFetchTool.selectedAsset(asset: asset)
        } else {
            assetFetchTool.deselectedAsset(asset: asset)
        }
    }
    
}

extension AssetPreviewViewController: AssetPreviewToolBarDelegate {
    
    func toolBar(_ toolBar: AssetPreviewToolBar, didSelectAsset asset: AssetModel) {
        guard let index = assetFetchTool.albumModel?.assets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) else {
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .top, animated: false)
        scrollViewDidEndDecelerating(collectionView)
    }
    
    func toolBarDidClickEditButton(_ toolBar: AssetPreviewToolBar) {
        guard let albumModel = assetFetchTool.albumModel else { return }
        
        let offsetIndex = Int(round(collectionView.contentOffset.x / collectionView.width))
        let assetModel = albumModel.assets[offsetIndex]
        
        if let _ = assetModel.previewImage {
            openEditViewController(assetModel)
        } else {
            LoadingHUD.shared.showLoading()
            let options = AssetFetchOptions()
            options.imageDeliveryMode = .highQualityFormat
            options.sizeOption = .specify(config.pickerConfig.maximumPreviewSize)
            
            AssetFetchTool.requestPhoto(for: assetModel.asset, options: options) { [weak self] result, _ in
                guard case .success(let response) = result else { return }
                assetModel.previewImage = response.image
                self?.openEditViewController(assetModel)
                LoadingHUD.shared.hideLoading()
            }
        }
    }
    
    func toolBarDidClickOriginButton(_ toolBar: AssetPreviewToolBar, isOriginal: Bool) {
        assetFetchTool.isOriginal = isOriginal
        deleagte?.imageBrowser(self, didChangeIsOriginal: isOriginal)
        
        guard isOriginal, let albumModel = assetFetchTool.albumModel else {
            return
        }
        let index = Int(collectionView.contentOffset.x / collectionView.width)
        let asset = albumModel.assets[index]
        
        if !asset.isSelected {
            assetFetchTool.selectedAsset(asset: asset)
        }
    }
    
    func toolBarDidClickDoneButton(_ toolBar: AssetPreviewToolBar) {
        var assets: [AssetModel] = []
        if assetFetchTool.selectedAssets.count > 0 {
            assets = assetFetchTool.selectedAssets
        } else {
            if let albumModel = assetFetchTool.albumModel {
                let offsetIndex = max(Int(round(collectionView.contentOffset.x / collectionView.width)), 0)
                assets.append(albumModel.assets[offsetIndex])
            }
        }
        deleagte?.imageBrowser(self, didClickDoneWithAssets: assets)
    }
    
}

extension AssetPreviewViewController: PhotoEditViewControllerDelegate {
    
    func editController(_ editController: PhotoEditViewController, didDidFinishEditAsset asset: AssetModel) {
        guard let index = assetFetchTool.albumModel?.assets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) else {
            return
        }
        assetFetchTool.selectedAsset(asset: asset)
        deleagte?.imageBrowser(self, didFinishEditImageAt: IndexPath(item: index, section: 0))
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
}

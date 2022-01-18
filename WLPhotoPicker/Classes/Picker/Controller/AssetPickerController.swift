//
//  AssetPickerController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos

protocol AssetPickerControllerDelegate: AnyObject {
    func pickerControllerDidCancel(_ pickerController: AssetPickerController)
    func pickerController(_ pickerController: AssetPickerController, didSelectResult result: [AssetPickerResult])
    func pickerController(_ pickerController: AssetPickerController, didOccurredError error: WLPhotoError)
}

class AssetPickerController: UIViewController {
    
    private var collectionView: UICollectionView!
    private let titleButton = AlbumTitleButton()
    private let bottomToolBar: AssetPickerToolBar
    private let deniedPermissionView = AssetPickerDeniedPermissionView()
    private weak var albumController: AlbumListViewController?
    
    weak var delegate: AssetPickerControllerDelegate?
    
    private let assetFetchTool: AssetFetchTool
    private let config: WLPhotoConfig
    
    // 是否显示相机
    var showsCameraItem: Bool {
        config.showCameraItem && (assetFetchTool.albumModel?.isCameraRollAlbum ?? false)
    }
    
    // 相机的indexPath
    var cameraItemIndexPath: IndexPath? {
        if !showsCameraItem {
            return nil
        }
        if config.pickerConfig.sortType == .desc {
            return IndexPath(item: 0, section: 0)
        } else {
            var indexPath = IndexPath(item: assetFetchTool.albumModel?.assets.count ?? 0, section: 0)
            if showsAddmoreAssetItem {
                indexPath.item += 1
            }
            return indexPath
        }
    }
    
    // 是否为选中照片权限
    var isLimitedPermission: Bool = false
    
    // 是否显示添加照片item
    var showsAddmoreAssetItem: Bool {
        let showLimited = config.pickerConfig.canAddMoreAssetWhenLimited && isLimitedPermission
        let isCameraRollAlbum = assetFetchTool.albumModel?.isCameraRollAlbum ?? false
        return showLimited && isCameraRollAlbum
    }
    
    // 添加照片的indexPath
    var addmoreAssetItemIndexPath: IndexPath? {
        if !showsAddmoreAssetItem {
            return nil
        }
        if config.pickerConfig.sortType == .desc {
            var indexPath = IndexPath(item: 0, section: 0)
            if showsCameraItem {
                indexPath.item += 1
            }
            return indexPath
        } else {
            return IndexPath(item: assetFetchTool.albumModel?.assets.count ?? 0, section: 0)
        }
    }
    
    init(config: WLPhotoConfig) {
        self.config = config
        bottomToolBar = AssetPickerToolBar(pickerConfig: config.pickerConfig)
        assetFetchTool = AssetFetchTool(config: config)
        super.init(nibName: nil, bundle: nil)
        assetFetchTool.addDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        requestPermission()
    }
    
    func setupView() {
        let cancelButton = UIButton()
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(WLPhotoPickerUIConfig.default.textColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        titleButton.isHidden = true
        titleButton.addTarget(self, action: #selector(showAlbumList), for: .touchUpInside)
        navigationItem.titleView = titleButton
        
        view.backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = config.pickerConfig.pickerSectionInset
        layout.minimumLineSpacing = config.pickerConfig.pickerRowSpace
        layout.minimumInteritemSpacing = config.pickerConfig.pickerColumnSpace
        layout.itemSize = config.pickerConfig.photoCollectionViewItemSize
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AssetCollectionViewCell.self)
        collectionView.register(AssetCameraCollectionViewCell.self)
        collectionView.register(AssetAddCollectionViewCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomToolBar.isHidden = true
        bottomToolBar.delegate = self
        view.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        deniedPermissionView.isHidden = true
        view.addSubview(deniedPermissionView)
        deniedPermissionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset.bottom = bottomToolBar.height - keyWindowSafeAreaInsets.bottom
        collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
    }
    
    func requestPermission() {
        PermissionProvider.request(.photoLibrary) { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                self.assetFetchTool.register()
                self.fetchAlbums()
            case .limited:
                self.assetFetchTool.register()
                self.isLimitedPermission = true
                self.bottomToolBar.isLimitedPermission = true
                self.fetchAlbums()
            default:
                self.deniedPermissionView.isHidden = false
            }
        }
    }
    
    func fetchAlbums() {
        assetFetchTool.fetchCameraRollAlbum()
        assetFetchTool.fetchAllAlbums()
    }
    
    private func setCurrentAlbum(_ albumModel: AlbumModel, reloadData: Bool = true, animated: Bool = false) {
        bottomToolBar.isHidden = false
        titleButton.isHidden = false
        titleButton.setTitle(albumModel.localizedTitle!)
        if reloadData {
            collectionView.reloadData()
        }
        let items = collectionView(collectionView, numberOfItemsInSection: 0)
        if config.pickerConfig.sortType == .asc {
            let indexPath = IndexPath(item: items - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        } else if items > 0 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: animated)
        }
    }
    
    func updateVisibleCells(_ animateIndex: Int? = nil) {
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell),
                  let cell = cell as? AssetCollectionViewCell,
                  let albumModel = assetFetchTool.albumModel else {
                      continue
                  }
            let newIndexPath = IndexPath(item: assetIndexFromCell(indexPath.item), section: 0)
            cell.update(albumModel.assets[newIndexPath.item], animated: animateIndex == newIndexPath.item)
        }
    }
    
    @objc func cancelButtonClick() {
        delegate?.pickerControllerDidCancel(self)
        if config.pickerConfig.autoDismissAfterDone {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func showAlbumList() {
        titleButton.isSelected.toggle()
        if titleButton.isSelected {
            let vc = AlbumListViewController(albumsList: assetFetchTool.albumsList, selectedAlbum: assetFetchTool.albumModel)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
            albumController = vc
        } else {
            albumController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // 降序排序时，前两个item可能为相机和添加照片，所以需要减去两个位置
    func assetIndexFromCell(_ index: Int) -> Int {
        var index = index
        if config.pickerConfig.sortType == .desc {
            if showsCameraItem {
                index -= 1
            }
            if showsAddmoreAssetItem {
                index -= 1
            }
        }
        return index
    }
    
    func cellIndexFromAsset(_ index: Int) -> Int {
        var index = index
        if config.pickerConfig.sortType == .desc {
            if showsCameraItem {
                index += 1
            }
            if showsAddmoreAssetItem {
                index += 1
            }
        }
        return index
    }
    
    // 跳转相机
    func openCaptureController() {
        let vc = CaptureViewController(config: config)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    // 点击完成，加载选中的资源
    func requestSelectedAssets(assets: [AssetModel]) {
        LoadingHUD.shared.showLoading()
        assetFetchTool.requestAssets(assets: assets) { progress in
            
        } completionHandle: { [weak self] result in
            guard let self = self else { return }
            LoadingHUD.shared.hideLoading()
            switch result {
            case .success(let assets):
                self.delegate?.pickerController(self, didSelectResult: assets)
            case .failure(let error):
                self.delegate?.pickerController(self, didOccurredError: error)
            }
        }
    }
    
}

// MARK: AssetFetchToolDelegate
extension AssetPickerController: AssetFetchToolDelegate {
    
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetchCameraAlbum albumModel: AlbumModel) {
        setCurrentAlbum(albumModel)
    }
    
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateAlbum albumModel: AlbumModel, insertedItems: IndexSet, removedItems: IndexSet, changedItems: IndexSet) {
        if removedItems.count > 0 {
            collectionView.deleteItems(at: removedItems.map {
                IndexPath(item: cellIndexFromAsset($0), section:0)
            })
        }
        if insertedItems.count > 0 {
            collectionView.insertItems(at: insertedItems.map {
                IndexPath(item: cellIndexFromAsset($0), section:0)
            })
        }
        if changedItems.count > 0 {
            collectionView.reloadItems(at: changedItems.map {
                IndexPath(item: cellIndexFromAsset($0), section:0)
            })
        }
        setCurrentAlbum(albumModel, reloadData: false, animated: true)
        updateVisibleCells()
        bottomToolBar.isEnabled = assetFetchTool.selectedAssets.count > 0
    }
    
    func assetFetchTool(_ fetchTool: AssetFetchTool, updateSelectedStatus assetModel: AssetModel) {
        guard let index = assetFetchTool.albumModel?.assets.firstIndex(where: {
            $0.localIdentifier == assetModel.localIdentifier
        }) else {
            return
        }
        updateVisibleCells(index)
        bottomToolBar.isEnabled = assetFetchTool.selectedAssets.count > 0
    }
    
}

extension AssetPickerController: AlbumListViewControllerDelegate {
    
    func albumList(_ viewController: AlbumListViewController, didSelect album: AlbumModel) {
        if assetFetchTool.albumModel?.localIdentifier == album.localIdentifier {
            return
        }
        assetFetchTool.selectedAssets.forEach {
            assetFetchTool.deselectedAsset(asset: $0)
        }
        assetFetchTool.albumModel = album
        setCurrentAlbum(album)
    }
    
    func albumListDidDismiss(_ viewController: AlbumListViewController) {
        titleButton.isSelected = false
    }
    
}

extension AssetPickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (assetFetchTool.albumModel?.count ?? 0) + (showsCameraItem ? 1 : 0) + (showsAddmoreAssetItem ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath == cameraItemIndexPath {
            return collectionView.dequeueReusableCell(AssetCameraCollectionViewCell.self, for: indexPath)
        }
        if indexPath == addmoreAssetItemIndexPath {
            return collectionView.dequeueReusableCell(AssetAddCollectionViewCell.self, for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(AssetCollectionViewCell.self, for: indexPath)
        guard let albumModel = assetFetchTool.albumModel else {
            return cell
        }
        let indexPath = IndexPath(item: assetIndexFromCell(indexPath.item), section: 0)
        cell.bind(albumModel.assets[indexPath.item], pickerConfig: config.pickerConfig)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == cameraItemIndexPath {
            openCaptureController()
            return
        }
        if indexPath == addmoreAssetItemIndexPath, #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            return
        }
        guard let albumModel = assetFetchTool.albumModel else {
            return
        }
        let indexPath = IndexPath(item: assetIndexFromCell(indexPath.item), section: 0)
        if !albumModel.assets[indexPath.item].isEnabled {
            return
        }
        let vc = AssetPreviewViewController(config: config, assetFetchTool: assetFetchTool)
        vc.animateDataSource = self
        vc.deleagte = self
        vc.currentIndex = indexPath.item
        self.present(vc, animated: true, completion: nil)
    }
}

extension AssetPickerController: AssetCollectionViewCellDelegate {
    
    func cell(_ cell: AssetCollectionViewCell, didChangeSelectedStatus selected: Bool) {
        guard let albumModel = assetFetchTool.albumModel,
              let indexPath = collectionView.indexPath(for: cell)  else {
                  return
              }
        let newIndexPath = IndexPath(item: assetIndexFromCell(indexPath.item), section: 0)
        let asset = albumModel.assets[newIndexPath.item]
        if selected {
            assetFetchTool.selectedAsset(asset: asset)
        } else {
            assetFetchTool.deselectedAsset(asset: asset)
        }
    }
    
}

// MARK: 预览页面回调和数据源
extension AssetPickerController: AssetPreviewViewControllerAnimateDataSource, AssetPreviewViewControllerDelegate {
    
    // 源imageView
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, sourceViewFor index: Int) -> UIImageView? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: cellIndexFromAsset(index), section: 0)) as? AssetCollectionViewCell else {
            return nil
        }
        return cell.assetImageView
    }
    
    // 资源尺寸
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, assetSizeFor index: Int) -> CGSize {
        guard let albumModel = assetFetchTool.albumModel else {
            return .zero
        }
        return albumModel.assets[index].asset.pixelSize
    }
    
    // 预览页面滚动到对应的index，当前页面滚动到对应位置
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didScrollTo indexPath: IndexPath) {
        collectionView.scrollToItem(at: IndexPath(item: cellIndexFromAsset(indexPath.item), section: 0),
                                    at: .centeredVertically,
                                    animated: false)
    }
    
    // 预览页面点击完成按钮
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didClickDoneWithAssets assets: [AssetModel]) {
        requestSelectedAssets(assets: assets)
    }
    
    // 预览页面点击是否原图按钮
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didChangeIsOrigin isOrigin: Bool) {
        bottomToolBar.isOrigin = assetFetchTool.isOrigin
    }
    
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didFinishEditImageAt indexPath: IndexPath) {
        let index = cellIndexFromAsset(indexPath.item)
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
}

// MARK: 底部toolBar回调
extension AssetPickerController: AssetPickerToolBarDelegate {
    
    // 点击无所有图片权限
    func pickerToolBarDidClickPermissionLimitedView(_ toolBar: AssetPickerToolBar) {
        UIApplication.shared.openSetting()
    }
    
    // 点击是否原图按钮
    func pickerToolBarDidClickOrginButton(_ toolBar: AssetPickerToolBar, isOrigin: Bool) {
        assetFetchTool.isOrigin = isOrigin
    }
    
    // 点击完成按钮
    func pickerToolBarDidClickDoneButton(_ toolBar: AssetPickerToolBar) {
        requestSelectedAssets(assets: assetFetchTool.selectedAssets)
    }
    
}

// MARK: 拍摄回调
extension AssetPickerController: CaptureViewControllerDelegate {
    
    // 拍摄照片
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingPhoto photo: UIImage) {
        AssetFetchTool.savePhoto(image: photo) { [weak self] result in
            guard let self = self,
                  case .success(let asset) = result else {
                      return
                  }
            self.assetFetchTool.captureLocalIdentifier = asset.localIdentifier
        }
    }
    
    // 拍摄视频
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL) {
        AssetFetchTool.saveVideo(url: videoUrl) { [weak self] result in
            guard let self = self,
                  case .success(let asset) = result else {
                      return
                  }
            self.assetFetchTool.captureLocalIdentifier = asset.localIdentifier
        }
    }
    
}

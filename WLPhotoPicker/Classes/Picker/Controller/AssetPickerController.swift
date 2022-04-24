//
//  AssetPickerController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import Photos
import MobileCoreServices

protocol AssetPickerControllerDelegate: AnyObject {
    func pickerControllerDidCancel(_ pickerController: AssetPickerController)
    func pickerController(_ pickerController: AssetPickerController, didSelectResult results: [PhotoPickerResult])
}

class AssetPickerController: UIViewController {
    
    weak var delegate: AssetPickerControllerDelegate?
    
    private var collectionView: UICollectionView!
    private let titleButton = AlbumTitleButton()
    private let bottomToolBar: AssetPickerToolBar
    private let deniedPermissionView = AssetPickerDeniedPermissionView()
    private weak var albumController: AlbumListViewController?
    
    var selectedIdentifiers: [String]?
    private let assetFetchTool: AssetFetchTool
    private let config: WLPhotoConfig
    
    // 是否显示相机
    private var showsCameraItem: Bool {
        config.pickerConfig.showsCameraItem && (assetFetchTool.albumModel?.isCameraRollAlbum ?? false)
    }
    
    // 相机的indexPath
    private var cameraItemIndexPath: IndexPath? {
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
    private var isLimitedPermission: Bool = false
    
    // 是否显示添加照片item
    private var showsAddmoreAssetItem: Bool {
        let showLimited = config.pickerConfig.canAddMoreAssetWhenLimited && isLimitedPermission
        let isCameraRollAlbum = assetFetchTool.albumModel?.isCameraRollAlbum ?? false
        return showLimited && isCameraRollAlbum
    }
    
    // 添加照片的indexPath
    private var addmoreAssetItemIndexPath: IndexPath? {
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
    
    private func setupView() {
        let cancelButton = UIButton()
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitle(BundleHelper.localizedString(.Cancel), for: .normal)
        cancelButton.setTitleColor(WLPhotoUIConfig.default.color.textColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        titleButton.isHidden = true
        titleButton.addTarget(self, action: #selector(showAlbumList), for: .touchUpInside)
        navigationItem.titleView = titleButton
        
        view.backgroundColor = WLPhotoUIConfig.default.color.pickerBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = config.pickerConfig.pickerSectionInset
        layout.minimumLineSpacing = config.pickerConfig.pickerRowSpace
        layout.minimumInteritemSpacing = config.pickerConfig.pickerColumnSpace
        layout.itemSize = config.pickerConfig.photoCollectionViewItemSize
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
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
    
    private func requestPermission() {
        assetFetchTool.selectedIdentifiers = selectedIdentifiers
        PermissionProvider.request(.photoLibrary) { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                self.assetFetchTool.register()
                self.assetFetchTool.fetchCameraRollAlbum()
                self.assetFetchTool.fetchAllAlbums()
            case .limited:
                self.assetFetchTool.register()
                self.isLimitedPermission = true
                self.bottomToolBar.isLimitedPermission = true
                self.assetFetchTool.fetchCameraRollAlbum()
                self.assetFetchTool.fetchAllAlbums()
            default:
                self.deniedPermissionView.isHidden = false
                self.collectionView.isHidden = true
                self.bottomToolBar.isHidden = true
            }
        }
    }
    
    private func setCurrentAlbum(_ albumModel: AlbumModel, reloadData: Bool = true, animated: Bool = false) {
        titleButton.isHidden = false
        titleButton.setTitle(albumModel.localizedTitle)
        bottomToolBar.isHidden = false
        if reloadData {
            collectionView.reloadData()
            scrollToLastImage()
        }
    }
    
    func scrollToLastImage(animated: Bool = false) {
        let items = collectionView(collectionView, numberOfItemsInSection: 0)
        if config.pickerConfig.sortType == .asc {
            let indexPath = IndexPath(item: items - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        } else if items > 0 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: animated)
        }
    }
    
    private func updateVisibleCells(_ animateIndex: Int? = nil) {
        for cell in collectionView.visibleCells {
            guard let albumModel = assetFetchTool.albumModel,
                  let indexPath = collectionView.indexPath(for: cell),
                  let cell = cell as? AssetCollectionViewCell else {
                      continue
                  }
            let newIndexPath = IndexPath(item: assetIndexFromCell(indexPath.item), section: 0)
            cell.update(albumModel.assets[newIndexPath.item], animated: animateIndex == newIndexPath.item)
        }
    }
    
    // 降序排序时，前两个item可能为相机和添加照片，所以需要减去两个位置
    private func assetIndexFromCell(_ index: Int) -> Int {
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
    
    private func cellIndexFromAsset(_ index: Int) -> Int {
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
    
    private func requestSelectedAssets(assets: [AssetModel]) {
        LoadingHUD.shared.showLoading()
        assetFetchTool.requestAssets(assets: assets) { [weak self] result in
            guard let self = self else { return }
            LoadingHUD.shared.hideLoading()
            switch result {
            case .success(let assets):
                self.delegate?.pickerController(self, didSelectResult: assets)
            case .failure(let error):
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }
    
    @objc private func cancelButtonClick() {
        delegate?.pickerControllerDidCancel(self)
    }
    
    @objc private func showAlbumList() {
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
    
    private func openCaptureController() {
        var captureMaximumVideoDuration = config.captureConfig.captureMaximumVideoDuration
        if config.pickerConfig.pickerMaximumVideoDuration > 0,
           captureMaximumVideoDuration > config.pickerConfig.pickerMaximumVideoDuration {
            captureMaximumVideoDuration = config.pickerConfig.pickerMaximumVideoDuration
        }
        
        if config.pickerConfig.useSystemImagePickerController {
            if !UIImagePickerController.isSourceTypeAvailable(.camera) { return }
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .camera
            vc.videoMaximumDuration = captureMaximumVideoDuration
            vc.mediaTypes = config.pickerConfig.imagePickerControllerMediaTypes
            vc.cameraFlashMode = config.captureConfig.captureFlashMode.cameraFlashMode
            vc.videoQuality = .typeHigh
            present(vc, animated: true, completion: nil)
        } else {
            config.captureConfig.captureMaximumVideoDuration = captureMaximumVideoDuration
            config.captureConfig.allowTakingPhoto = config.pickerConfig.allowTakingPhoto
            config.captureConfig.allowTakingVideo = config.pickerConfig.allowTakingVideo
            let vc = CaptureViewController(captureConfig: config.captureConfig,
                                           photoEditConfig: config.pickerConfig.allowEditPhoto ? config.photoEditConfig : nil)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController.init(title: BundleHelper.localizedString(.Alert), message: message, preferredStyle: .alert)
        alert.addAction(.init(title: BundleHelper.localizedString(.Confirm), style: .cancel, handler: nil))
        var vc: UIViewController = self
        if let presentedViewController = self.presentedViewController {
            vc = presentedViewController
        }
        vc.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset.bottom = bottomToolBar.height - keyWindowSafeAreaInsets.bottom
        collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
    }
    
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension AssetPickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = assetFetchTool.albumModel?.count ?? 0
        if showsCameraItem {
            count += 1
        }
        if showsAddmoreAssetItem {
            count += 1
        }
        return count
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetCollectionViewCell,
              let albumModel = assetFetchTool.albumModel else {
                  return
              }
        let indexPath = IndexPath(item: assetIndexFromCell(indexPath.item), section: 0)
        cell.update(albumModel.assets[indexPath.item], animated: false)
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
        let assetModel = albumModel.assets[indexPath.item]
        if !assetModel.isEnabled {
            return
        }
        if config.pickerConfig.allowPreview {
            let vc = AssetPreviewViewController(config: config, assetFetchTool: assetFetchTool)
            vc.animateDataSource = self
            vc.deleagte = self
            vc.currentIndex = indexPath.item
            present(vc, animated: true, completion: nil)
        } else {
            requestSelectedAssets(assets: [assetModel])
        }
    }
}

// MARK: AssetCollectionViewCellDelegate
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

// MARK: AssetFetchToolDelegate
extension AssetPickerController: AssetFetchToolDelegate {
    
    func assetFetchTool(_ fetchTool: AssetFetchTool, finishFetchCameraAlbum albumModel: AlbumModel) {
        setCurrentAlbum(albumModel)
        bottomToolBar.isEnabled = assetFetchTool.selectedAssets.count > 0
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
        if insertedItems.count > 0 {
            scrollToLastImage(animated: true)
        }
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
    
    func assetFetchToolSelectUpToLimited(_ fetchTool: AssetFetchTool) {
        showErrorAlert(BundleHelper.localizedString(.CountLimitedTip, config.pickerConfig.selectCountLimit))
    }
    
}

// MARK: AssetPickerToolBarDelegate
extension AssetPickerController: AssetPickerToolBarDelegate {
    
    func pickerToolBarDidClickPermissionLimitedView(_ toolBar: AssetPickerToolBar) {
        UIApplication.shared.openSetting()
    }
    
    func pickerToolBarDidClickOrginButton(_ toolBar: AssetPickerToolBar, isOriginal: Bool) {
        assetFetchTool.isOriginal = isOriginal
    }
    
    func pickerToolBarDidClickDoneButton(_ toolBar: AssetPickerToolBar) {
        requestSelectedAssets(assets: assetFetchTool.selectedAssets)
    }
    
}

// MARK: AlbumListViewControllerDelegate
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

// MARK: AssetPreviewViewControllerAnimateDataSource & AssetPreviewViewControllerDelegate
extension AssetPickerController: AssetPreviewViewControllerAnimateDataSource, AssetPreviewViewControllerDelegate {
    
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, sourceViewFor index: Int) -> UIImageView? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: cellIndexFromAsset(index), section: 0)) as? AssetCollectionViewCell else {
            return nil
        }
        return cell.assetImageView
    }
    
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didScrollTo indexPath: IndexPath) {
        collectionView.scrollToItem(at: IndexPath(item: cellIndexFromAsset(indexPath.item), section: 0),
                                    at: .centeredVertically,
                                    animated: false)
    }
    
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didClickDoneWithAssets assets: [AssetModel]) {
        requestSelectedAssets(assets: assets)
    }
    
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didChangeIsOriginal isOriginal: Bool) {
        bottomToolBar.isOriginal = assetFetchTool.isOriginal
    }
    
    func imageBrowser(_ imageBrowser: AssetPreviewViewController, didFinishEditImageAt indexPath: IndexPath) {
        let index = cellIndexFromAsset(indexPath.item)
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
}

// MARK: CaptureViewControllerDelegate
extension AssetPickerController: CaptureViewControllerDelegate {
    
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingPhoto photo: UIImage) {
        viewController.presentingViewController?.dismiss(animated: true)
        AssetSaveManager.savePhoto(photo: photo) { [weak self] asset in
            self?.assetFetchTool.captureLocalIdentifier = asset.localIdentifier
        }
    }
    
    func captureViewController(_ viewController: CaptureViewController, didFinishTakingVideo videoUrl: URL) {
        viewController.presentingViewController?.dismiss(animated: true)
        AssetSaveManager.saveVideo(videoURL: videoUrl) { [weak self] asset in
            self?.assetFetchTool.captureLocalIdentifier = asset.localIdentifier
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AssetPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let mediaType = info[.mediaType] as? String else {
            return
        }
        
        if mediaType == kUTTypeImage as String, let originalImage = info[.originalImage] as? UIImage {
            AssetSaveManager.savePhoto(photo: originalImage) { [weak self] asset in
                self?.assetFetchTool.captureLocalIdentifier = asset.localIdentifier
            }
        }
        
        if mediaType == kUTTypeMovie as String, let mediaURL = info[.mediaURL] as? URL {
            AssetSaveManager.saveVideo(videoURL: mediaURL) { [weak self] asset in
                self?.assetFetchTool.captureLocalIdentifier = asset.localIdentifier
            }
        }
        
    }
    
}

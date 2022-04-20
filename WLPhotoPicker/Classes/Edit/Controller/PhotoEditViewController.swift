//
//  PhotoEditViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit
import Photos

public protocol PhotoEditViewControllerDelegate: AnyObject {
    func editController(_ editController: PhotoEditViewController, didDidFinishEditAsset asset: AssetModel)
    func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?)
}

public extension PhotoEditViewControllerDelegate {
    func editController(_ editController: PhotoEditViewController, didDidFinishEditAsset asset: AssetModel) { }
    func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?) { }
}

public class PhotoEditViewController: UIViewController {
    
    weak var delegate: PhotoEditViewControllerDelegate?
    
    private let photo: UIImage
    private let assetModel: AssetModel?
    private let photoEditConfig: PhotoEditConfig
    private var currentEditItemType: PhotoEditItemType?
    
    var originalImageViewSize: CGSize = .zero
    
    let editContentView = UIView()
    let contentScrollView = UIScrollView()
    let imageContainerView = UIImageView()
    let contentImageView = UIImageView()
    let contentImageViewMask = CAShapeLayer()
    let topToolBar = PhotoEditTopToolBar()
    let bottomToolBar: PhotoEditBottomToolBar
    private let masksTrashCanView = PhotoEditMaskTrashCanView()
    private let adjustSlideView = PhotoEditAdjustSlideView()
    
    private let singleTapGesture = UITapGestureRecognizer()
    
    private var graffitiDrawColor: UIColor = .clear
    private let graffitiDrawLayer = CALayer()
    private let graffitiDrawGesture = UIPanGestureRecognizer()
    
    private var mosaicMaskImage: UIImage?
    private var mosaicDrawLayer = CALayer()
    private var mosaicDrawMaskLayer = CAShapeLayer()
    private let mosaicDrawGesture = UIPanGestureRecognizer()
    
    let maskLayerContentView = UIView()
    private let masksTapGesture = UITapGestureRecognizer()
    private let masksPanGesture = UIPanGestureRecognizer()
    private let masksPinchGesture = UIPinchGestureRecognizer()
    private let masksRotationGesture = UIRotationGestureRecognizer()
    
    private var hasHighlightMasksTrashCanView: Bool = false
    private var maskSubviews: [PhotoEditMaskView] {
        maskLayerContentView.subviews.compactMap {
            $0 as? PhotoEditMaskView
        }
    }
    
    private var imageBeforeAdjust: UIImage?
    private var currentAdjustMode: PhotoEditAdjustMode?
    
    let editManager: EditManager
    
    public override var prefersStatusBarHidden: Bool {
        true
    }
    
    public init(photo: UIImage, assetModel: AssetModel? = nil, photoEditConfig: PhotoEditConfig) {
        self.photo = photo
        self.assetModel = assetModel
        self.editManager = EditManager(photo: photo, assetModel: assetModel)
        self.photoEditConfig = photoEditConfig
        self.bottomToolBar = PhotoEditBottomToolBar(photo: photo, photoEditConfig: photoEditConfig)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupGesture()
        setupPhoto()
        setupEditedImage()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        
        editContentView.backgroundColor = .black
        view.addSubview(editContentView)
        editContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentScrollView.contentInsetAdjustmentBehavior = .never
        contentScrollView.clipsToBounds = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.isUserInteractionEnabled = true
        contentScrollView.delegate = self
        contentScrollView.setZoomScale(1.0, animated: false)
        contentScrollView.minimumZoomScale = 1
        contentScrollView.bouncesZoom = true
        contentScrollView.backgroundColor = .clear
        editContentView.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.clipsToBounds = true
        imageContainerView.isUserInteractionEnabled = true
        contentScrollView.addSubview(imageContainerView)
        
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.isUserInteractionEnabled = true
        contentImageView.layer.mask = contentImageViewMask
        imageContainerView.addSubview(contentImageView)
        
        contentImageView.layer.addSublayer(graffitiDrawLayer)
        
        mosaicDrawMaskLayer.strokeColor = UIColor.black.cgColor
        mosaicDrawMaskLayer.fillColor = nil
        mosaicDrawMaskLayer.lineCap = .round
        mosaicDrawMaskLayer.lineJoin = .round
        mosaicDrawLayer.mask = mosaicDrawMaskLayer
        contentImageView.layer.insertSublayer(mosaicDrawLayer, at: 0)
        
        maskLayerContentView.layer.masksToBounds = false
        imageContainerView.addSubview(maskLayerContentView)
        
        topToolBar.delegate = self
        view.addSubview(topToolBar)
        topToolBar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        
        bottomToolBar.delegate = self
        view.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        masksTrashCanView.isHidden = true
        view.addSubview(masksTrashCanView)
        masksTrashCanView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(0)
        }
        
        adjustSlideView.addTarget(self, action: #selector(adjustSlideValueChange), for: .valueChanged)
        adjustSlideView.isHidden = true
        view.addSubview(adjustSlideView)
        adjustSlideView.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.bottom.equalTo(bottomToolBar.snp.top).offset(16)
        }
    }
    
    private func setupGesture() {
        singleTapGesture.addTarget(self, action: #selector(contentViewSingleTap))
        singleTapGesture.delegate = self
        editContentView.addGestureRecognizer(singleTapGesture)
        
        graffitiDrawGesture.addTarget(self, action: #selector(graffitiDraw(_:)))
        graffitiDrawGesture.delegate = self
        graffitiDrawGesture.maximumNumberOfTouches = 1
        contentScrollView.panGestureRecognizer.require(toFail: graffitiDrawGesture)
        editContentView.addGestureRecognizer(graffitiDrawGesture)
        
        mosaicDrawGesture.addTarget(self, action: #selector(mosaicDraw(_:)))
        mosaicDrawGesture.delegate = self
        mosaicDrawGesture.maximumNumberOfTouches = 1
        contentScrollView.panGestureRecognizer.require(toFail: mosaicDrawGesture)
        editContentView.addGestureRecognizer(mosaicDrawGesture)
        
        masksTapGesture.addTarget(self, action: #selector(handleMasksTapGesture(_:)))
        masksTapGesture.delegate = self
        masksTapGesture.numberOfTouchesRequired = 1
        maskLayerContentView.addGestureRecognizer(masksTapGesture)
        
        masksPanGesture.addTarget(self, action: #selector(handleMasksPanGesture(_:)))
        masksPanGesture.delegate = self
        masksPanGesture.maximumNumberOfTouches = 2
        contentScrollView.panGestureRecognizer.require(toFail: masksPanGesture)
        maskLayerContentView.addGestureRecognizer(masksPanGesture)
        
        masksPinchGesture.addTarget(self, action: #selector(handleMasksPinchGesture(_:)))
        masksPinchGesture.delegate = self
        contentScrollView.pinchGestureRecognizer?.require(toFail: masksPinchGesture)
        maskLayerContentView.addGestureRecognizer(masksPinchGesture)
        
        masksRotationGesture.addTarget(self, action: #selector(handleMasksRotationGesture(_:)))
        masksRotationGesture.delegate = self
        contentScrollView.pinchGestureRecognizer?.require(toFail: masksRotationGesture)
        maskLayerContentView.addGestureRecognizer(masksRotationGesture)
        
        masksTapGesture.require(toFail: masksPanGesture)
    }
    
    private func setupPhoto() {
        contentImageView.image = assetModel?.editedImage ?? photo
        
        imageContainerView.frame = AssetDisplayHelper.imageViewRectFrom(imageSize: photo.size, mediaType: .photo)
        originalImageViewSize = imageContainerView.size
        
        contentScrollView.contentSize = imageContainerView.size
        contentScrollView.maximumZoomScale = AssetDisplayHelper.imageViewMaxZoomScaleFrom(imageSize: photo.size)
        
        contentImageView.frame = imageContainerView.bounds
        
        editManager.editGraffitiPath.contextSize = photo.size
        editManager.editGraffitiPath.drawedViewSize = imageContainerView.size
        graffitiDrawLayer.frame = imageContainerView.bounds
        
        editManager.editMosaicPath.drawedViewSize = imageContainerView.size
        mosaicDrawLayer.frame = imageContainerView.bounds
        
        maskLayerContentView.frame = imageContainerView.bounds
        
        photoEditConfig.photoEditAdjustModes.forEach {
            editManager.adjustValue[$0] = 0
        }
        
        updateContentImageViewMask()
    }
    
    private func setupEditedImage() {
        guard let assetModel = self.assetModel, assetModel.hasEdit else { return }
        bottomToolBar.selectedFilterIndex = assetModel.photoFilterIndex
        
        let mosaicImage = photo.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        let mosaicDrawedImage = editManager.editMosaicPath.drawMosaicImage(ornginalImage: photo, mosaicImage: mosaicImage)
        let filterImage = editManager.photoFilter?.filter?(mosaicDrawedImage) ?? mosaicDrawedImage
        let adjustedImage = filterImage?.adjustImageFrom(editManager.adjustValue)
        contentImageView.image = adjustedImage
        
        graffitiDrawLayer.contents = editManager.editGraffitiPath.draw()?.cgImage
        graffitiDrawLayer.removeAllAnimations()
        
        for maskLayer in assetModel.maskLayers {
            let maskView = PhotoEditMaskView(maskLayer: maskLayer)
            maskView.updateMaskLayer(showActive: false)
            self.maskLayerContentView.addSubview(maskView)
        }
        layoutCropedImageView()
    }
    
    @objc private func contentViewSingleTap() {
        dismissAllMaskActive()
        setToolBarsHidden(bottomToolBar.alpha == 1)
    }
    
    private func setToolBarsHidden(_ isHidden: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.topToolBar.alpha = isHidden ? 0 : 1
            self.bottomToolBar.alpha = isHidden ? 0 : 1
            self.adjustSlideView.alpha = isHidden ? 0 : 1
        }
    }
    
    private func updateContentImageViewMask() {
        let maskFrame = contentScrollView.convert(imageContainerView.frame, to: contentImageView)
        contentImageViewMask.path = UIBezierPath.init(rect: maskFrame).cgPath
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

// MARK: Graffiti
extension PhotoEditViewController {
    
    @objc private func graffitiDraw(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: contentImageView)
        let zoomScale = contentScrollView.zoomScale
        let contentImageViewSize = imageContainerView.convert(contentImageView.frame, to: view).size
        var rotateScale = contentImageViewSize.width / originalImageViewSize.width
        if editManager.cropRotation.isLandscape {
            rotateScale = contentImageViewSize.height / originalImageViewSize.width
        }
        switch gesture.state {
        case .began:
            let lineWidth = photoEditConfig.photoEditGraffitiLineWidth / zoomScale / rotateScale
            let pathLine = PhotoEditGraffitiPathLine(graffitiColor: graffitiDrawColor,
                                                     lineWidth: lineWidth,
                                                     startPoint: location)
            editManager.editGraffitiPath.append(pathLine: pathLine)
            setToolBarsHidden(true)
        case .changed:
            editManager.editGraffitiPath.last?.addLine(to: location)
            graffitiDrawLayer.contents = editManager.editGraffitiPath.draw()?.cgImage
        default:
            setToolBarsHidden(false)
        }
    }
    
}

// MARK: Mosaic
extension PhotoEditViewController {
    
    private func prepareForMosaic() {
        let mosaicImage = photo.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        let filterImage = editManager.photoFilter?.filter?(mosaicImage) ?? mosaicImage
        let adjustedImage = filterImage.adjustImageFrom(editManager.adjustValue)
        mosaicMaskImage = adjustedImage
        mosaicDrawLayer.contents = mosaicMaskImage?.cgImage
    }
    
    private func drawMosaicImage()  {
        let filterImage = editManager.photoFilter?.filter?(photo) ?? photo
        let adjustedImage = filterImage.adjustImageFrom(editManager.adjustValue)
        contentImageView.image = editManager.editMosaicPath.drawMosaicImage(ornginalImage: adjustedImage, mosaicImage: mosaicMaskImage)
    }
    
    @objc private func mosaicDraw(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: contentImageView)
        let zoomScale = contentScrollView.zoomScale
        let contentImageViewSize = imageContainerView.convert(contentImageView.frame, to: view).size
        var rotateScale = contentImageViewSize.width / originalImageViewSize.width
        if editManager.cropRotation.isLandscape {
            rotateScale = contentImageViewSize.height / originalImageViewSize.width
        }
        switch gesture.state {
        case .began:
            let lineWidth = photoEditConfig.photoEditMosaicLineWidth / zoomScale / rotateScale
            mosaicDrawMaskLayer.lineWidth = lineWidth
            mosaicDrawMaskLayer.removeAllAnimations()
            let pathLine = PhotoEditMosaicPathLine(lineWidth: lineWidth,
                                                   startPoint: location)
            editManager.editMosaicPath.append(pathLine: pathLine)
            setToolBarsHidden(true)
        case .changed:
            editManager.editMosaicPath.last?.addLine(to: location)
            mosaicDrawMaskLayer.path = editManager.editMosaicPath.last?.drawPath()
        default:
            mosaicDrawMaskLayer.path = nil
            setToolBarsHidden(false)
            drawMosaicImage()
        }
    }
    
}

// MARK: MaskLayer
extension PhotoEditViewController {
    
    private func showEditTextController(textMaskLayer: PhotoEditTextMaskLayer?) {
        let backgroundImage = editContentView.screenShot(scale: 1)
        let vc = PhotoEditTextViewController(backgroundImage: backgroundImage,
                                             textMaskLayer: textMaskLayer,
                                             photoEditConfig: photoEditConfig)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private func addMaskLayer(maskLayer: PhotoEditMaskLayer) {
        var maskLayer = maskLayer
        let viewCenter = CGPoint(x: UIScreen.width * 0.5, y: UIScreen.height * 0.5)
        maskLayer.center = view.convert(viewCenter, to: maskLayerContentView)
        maskLayer.rotation = -editManager.cropRotation.rotationAngle
        let maskView = PhotoEditMaskView(maskLayer: maskLayer)
        maskLayerContentView.addSubview(maskView)
        dismissAllMaskActive()
        maskView.updateMaskLayer()
    }
    
    private func maskViewAt(_ location: CGPoint) -> PhotoEditMaskView? {
        return maskSubviews.last(where: { $0.frame.contains(location) })
    }
    
    private func activeMaskView() -> PhotoEditMaskView? {
        return maskSubviews.first(where: { $0.isActive })
    }
    
    private func showMaskActiveAt(_ location: CGPoint) {
        guard let maskView = maskViewAt(location) else {
            return
        }
        dismissAllMaskActive()
        maskView.showActive()
        maskLayerContentView.bringSubviewToFront(maskView)
    }
    
    private func dismissAllMaskActive() {
        maskSubviews.forEach {
            $0.dismissActive()
        }
    }
    
    private func maskGestureBeginAt(_ location: CGPoint) {
        hasHighlightMasksTrashCanView = false
        setTrashCanViweHidden(false, animated: true)
        setToolBarsHidden(true)
        showMaskActiveAt(location)
    }
    
    private func setTrashCanViweHidden(_ isHidden: Bool, animated: Bool) {
        masksTrashCanView.isHidden = isHidden
        UIView.animate(withDuration: animated ? 0.15 : 0) {
            self.masksTrashCanView.snp.updateConstraints { make in
                make.bottom.equalTo(isHidden ? 0 : (-keyWindowSafeAreaInsets.bottom - 10))
            }
            self.masksTrashCanView.alpha = isHidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleMasksTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: maskLayerContentView)
        guard let maskView = maskViewAt(location) else {
            return
        }
        if maskView.isActive, let textMaskLayer = maskView.maskLayer as? PhotoEditTextMaskLayer {
            maskView.isHidden = true
            showEditTextController(textMaskLayer: textMaskLayer)
        } else {
            showMaskActiveAt(location)
        }
    }
    
    @objc private func handleMasksPanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: maskLayerContentView)
        switch gesture.state {
        case .began:
            imageContainerView.clipsToBounds = false
            maskGestureBeginAt(location)
        case .changed:
            guard let maskView = activeMaskView() else { return }
            let translation = gesture.translation(in: maskLayerContentView)
            maskView.maskLayer.translation = CGPoint(x: maskView.maskLayer.translation.x + translation.x,
                                                     y: maskView.maskLayer.translation.y + translation.y)
            gesture.setTranslation(.zero, in: maskLayerContentView)
            maskView.updateMaskLayer(dismissLater: false)
            let viewLocation = maskLayerContentView.convert(location, to: view)
            let isLocationInTrashCan = masksTrashCanView.frame.contains(viewLocation)
            masksTrashCanView.isHighlighted = isLocationInTrashCan
            if isLocationInTrashCan {
                hasHighlightMasksTrashCanView = true
            } else if hasHighlightMasksTrashCanView {
                setTrashCanViweHidden(true, animated: false)
            }
        case .cancelled, .ended:
            setToolBarsHidden(false)
            guard let maskView = activeMaskView() else { return }
            if masksTrashCanView.isHighlighted && !masksTrashCanView.isHidden {
                maskView.removeFromSuperview()
                setTrashCanViweHidden(true, animated: false)
                return
            }
            setTrashCanViweHidden(true, animated: true)
            let viewLocation = maskLayerContentView.convert(location, to: view)
            if imageContainerView.frame.contains(viewLocation) {
                imageContainerView.clipsToBounds = true
                maskView.showActive()
            } else {
                let viewCenter = CGPoint(x: UIScreen.width * 0.5, y: UIScreen.height * 0.5)
                maskView.maskLayer.center = view.convert(viewCenter, to: maskLayerContentView)
                maskView.maskLayer.translation = .zero
                maskView.updateMaskLayer(animate: true) {
                    self.imageContainerView.clipsToBounds = true
                }
            }
        default:
            break
        }
    }
    
    @objc private func handleMasksPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            maskGestureBeginAt(gesture.location(in: maskLayerContentView))
        case .changed:
            guard let maskView = activeMaskView() else { return }
            maskView.maskLayer.scale = maskView.maskLayer.scale + gesture.scale - 1
            gesture.scale = 1
            maskView.updateMaskLayer(dismissLater: false)
        case .cancelled, .ended:
            setToolBarsHidden(false)
            setTrashCanViweHidden(true, animated: true)
        default:
            break
        }
    }
    
    @objc private func handleMasksRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: maskLayerContentView)
        switch gesture.state {
        case .began:
            maskGestureBeginAt(location)
        case .changed:
            guard let maskView = activeMaskView() else { return }
            maskView.maskLayer.rotation = gesture.rotation + maskView.maskLayer.rotation
            gesture.rotation = 0
            maskView.updateMaskLayer(dismissLater: false)
        case .cancelled, .ended:
            setToolBarsHidden(false)
            setTrashCanViweHidden(true, animated: true)
        default:
            break
        }
    }
    
}

// MARK: Crop
extension PhotoEditViewController {
    
    func layoutCropedImageView() {
        let photoSize = editManager.cropRotation.isPortrait ? photo.size : photo.size.turn
        let cropedImageRect = editManager.cropRect.convertSizeToRect(photoSize)
        let toDisplayFrame = AssetDisplayHelper.imageViewRectFrom(imageSize: cropedImageRect.size, mediaType: .photo)
        
        imageContainerView.frame = toDisplayFrame
        contentScrollView.contentSize = toDisplayFrame.size
        
        let rotationAngle = editManager.cropRotation.rotationAngle
        let imageDisplayScale = cropedImageRect.width / toDisplayFrame.width
        let targetDisplaySize = CGSize(width: photoSize.width / imageDisplayScale, height: photoSize.height / imageDisplayScale)
        let zoomScale = targetDisplaySize.width / (editManager.cropRotation.isPortrait ? originalImageViewSize.width : originalImageViewSize.height)
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
            .scaledBy(x: zoomScale, y: zoomScale)
        
        let targetDisplayOrigin = CGPoint(x: -targetDisplaySize.width * editManager.cropRect.x, y: -targetDisplaySize.height * editManager.cropRect.y)
        contentImageView.transform = transform
        contentImageView.frame.origin = targetDisplayOrigin
        
        maskLayerContentView.transform = transform
        maskLayerContentView.frame = contentImageView.frame
        
        updateContentImageViewMask()
    }
    
}

// MARK: Filter
extension PhotoEditViewController {
    
    private func drawFilterImage(filter: PhotoEditFilterProvider) {
        editManager.photoFilter = filter
        let mosaicImage = photo.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        let mosaicDrawedImage = editManager.editMosaicPath.drawMosaicImage(ornginalImage: photo, mosaicImage: mosaicImage)
        let filterImage = editManager.photoFilter?.filter?(mosaicDrawedImage) ?? mosaicDrawedImage
        let adjustedImage = filterImage?.adjustImageFrom(editManager.adjustValue)
        contentImageView.image = adjustedImage
    }
    
}

// MARK: Adjust
extension PhotoEditViewController {
    
    @objc private func adjustSlideValueChange() {
        changeAdjustValue(adjustSlideView.value)
    }
    
    private func prepareForAdjust() {
        let mosaicImage = photo.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        let mosaicDrawedImage = editManager.editMosaicPath.drawMosaicImage(ornginalImage: photo, mosaicImage: mosaicImage)
        let filterImage = editManager.photoFilter?.filter?(mosaicDrawedImage) ?? mosaicDrawedImage
        imageBeforeAdjust = filterImage
    }
    
    private func changeAdjustValue(_ value: Double) {
        guard let currentAdjustMode = self.currentAdjustMode  else {
            return
        }
        editManager.adjustValue[currentAdjustMode] = value
        contentImageView.image = imageBeforeAdjust?.adjustImageFrom(editManager.adjustValue)
    }
    
}

// MARK: UIScrollViewDelegate
extension PhotoEditViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageContainerView.center = scrollView.zoomSubviewCenter
    }
}

// MARK: UIGestureRecognizerDelegate
extension PhotoEditViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.view == self.maskLayerContentView && otherGestureRecognizer.view == self.maskLayerContentView
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == maskLayerContentView {
            let location = gestureRecognizer.location(in: maskLayerContentView)
            if let _ = maskLayerContentView.subviews.first(where: { $0.frame.contains(location) }) as? PhotoEditMaskView {
                return true
            } else {
                return false
            }
        }
        if gestureRecognizer == graffitiDrawGesture {
            return currentEditItemType == .graffiti
        }
        if gestureRecognizer == mosaicDrawGesture {
            return currentEditItemType == .mosaic
        }
        return true
    }
    
}

// MARK: TopToolBarDelegate
extension PhotoEditViewController: PhotoEditTopToolBarDelegate {
    
    func topToolBarDidClickCancelButton(_ topToolBar: PhotoEditTopToolBar) {
        dismiss(animated: false, completion: nil)
    }
    
}

// MARK: BottomToolBarDelegate
extension PhotoEditViewController: PhotoEditBottomToolBarDelegate {
    
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectItemType itemType: PhotoEditItemType?) {
        if itemType?.canBeHighlight ?? true {
            currentEditItemType = itemType
        }
        dismissAllMaskActive()
        adjustSlideView.isHidden = itemType != .adjust
        switch itemType {
        case .paster:
            let vc = PhotoEditPasterViewController(photoEditConfig: photoEditConfig)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        case .text:
            showEditTextController(textMaskLayer: nil)
        case .crop:
            editManager.maskLayers = maskSubviews.map { $0.maskLayer }
            guard let editedImage = editManager.drawOverlay(at: contentImageView.image, withCrop: false) else { return }
            let vc = PhotoEditCropViewController(photo: editedImage, cropRect: editManager.cropRect, cropRotation: editManager.cropRotation, photoEditCropRatios: photoEditConfig.photoEditCropRatios)
            vc.delegate = self
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = vc
            present(vc, animated: true, completion: { [unowned self] in
                self.contentScrollView.zoomScale = 1
            })
        case .mosaic:
            prepareForMosaic()
        case .adjust:
            prepareForAdjust()
        default:
            break
        }
    }
    
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectGraffitiColor graffitiColor: UIColor) {
        graffitiDrawColor = graffitiColor
    }
    
    func bottomToolBarDidClickGraffitiUndoButton(_ bottomToolBar: PhotoEditBottomToolBar) {
        editManager.editGraffitiPath.removeLast()
        graffitiDrawLayer.contents = editManager.editGraffitiPath.draw()?.cgImage
        graffitiDrawLayer.removeAllAnimations()
    }
    
    func bottomToolBarDidClickMosaicUndoButton(_ bottomToolBar: PhotoEditBottomToolBar) {
        editManager.editMosaicPath.removeLast()
        drawMosaicImage()
    }
    
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectFilter filter: PhotoEditFilterProvider, index: Int) {
        editManager.selectedFilterIndex = index
        drawFilterImage(filter: filter)
    }
    
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectAdjustMode adjustMode: PhotoEditAdjustMode) {
        adjustSlideView.minimumValue = adjustMode.minimumValue
        currentAdjustMode = adjustMode
        if let value = editManager.adjustValue[adjustMode] {
            adjustSlideView.value = value
        }
    }
    
    func bottomToolBarDidClickDoneButton(_ bottomToolBar: PhotoEditBottomToolBar) {
        editManager.maskLayers = maskSubviews.map { $0.maskLayer }
        let editedImage = editManager.drawOverlay(at: contentImageView.image, withCrop: true)
        
        if let assetModel = self.assetModel {
            assetModel.editMosaicPath = editManager.editMosaicPath
            assetModel.editGraffitiPath = editManager.editGraffitiPath
            assetModel.maskLayers = editManager.maskLayers
            assetModel.cropRect = editManager.cropRect
            assetModel.cropRotation = editManager.cropRotation
            assetModel.photoFilter = editManager.photoFilter
            assetModel.photoFilterIndex = editManager.selectedFilterIndex
            assetModel.adjustValue = editManager.adjustValue
            assetModel.editedImage = editedImage
            delegate?.editController(self, didDidFinishEditAsset: assetModel)
        } else {
            delegate?.editController(self, didDidFinishEditPhoto: editedImage)
        }
        
        dismiss(animated: false, completion: nil)
    }
}

// MARK: PasterViewControllerDelegate
extension PhotoEditViewController: PhotoEditPasterViewControllerDelegate {
    
    func pasterController(_ pasterController: PhotoEditPasterViewController, didSelectPasterImage image: UIImage) {
        addMaskLayer(maskLayer: PhotoEditPasterMaskLayer(maskImage: image))
    }
    
}

// MARK: TextViewControllerDelegate
extension PhotoEditViewController: PhotoEditTextViewControllerDelegate {
    
    func textMaskViewFrom(id: Double) -> PhotoEditMaskView? {
        maskSubviews.first(where:  {
            ($0.maskLayer as? PhotoEditTextMaskLayer)?.id == id
        })
    }
    
    func textController(_ textController: PhotoEditTextViewController, didCancelImput maskLayer: PhotoEditTextMaskLayer?) {
        guard let maskLayer = maskLayer else { return }
        if let maskView = textMaskViewFrom(id: maskLayer.id) {
            maskView.isHidden = false
            maskView.showActive()
        }
    }
    
    func textController(_ textController: PhotoEditTextViewController, didFinishInput maskLayer: PhotoEditTextMaskLayer) {
        if let maskView = textMaskViewFrom(id: maskLayer.id) {
            maskView.isHidden = false
            maskView.maskLayer = maskLayer
            maskView.reset()
            maskView.updateMaskLayer()
        } else {
            addMaskLayer(maskLayer: maskLayer)
        }
    }
    
}

// MARK: PhotoEditCropViewControllerDelegate
extension PhotoEditViewController: PhotoEditCropViewControllerDelegate {
    
    public func cropViewController(_ viewController: PhotoEditCropViewController, didFinishCrop image: UIImage, cropRect: PhotoEditCropRect, rotation: UIImage.Orientation) {
        editManager.cropRect = cropRect
        editManager.cropRotation = rotation
        layoutCropedImageView()
    }
    
}

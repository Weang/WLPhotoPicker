//
//  PhotoEditViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit
import Photos

protocol PhotoEditViewControllerDelegate: AnyObject {
    func editController(_ editController: PhotoEditViewController, didDidFinishEditAsset asset: AssetModel)
    func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?)
}

extension PhotoEditViewControllerDelegate {
    func editController(_ editController: PhotoEditViewController, didDidFinishEditAsset asset: AssetModel) { }
    func editController(_ editController: PhotoEditViewController, didDidFinishEditPhoto photo: UIImage?) { }
}

public class PhotoEditViewController: UIViewController {
    
    weak var delegate: PhotoEditViewControllerDelegate?
    
    let photo: UIImage?
    let assetModel: AssetModel?
    let photoEditConfig: PhotoEditConfig
    
    var currentEditItemType: PhotoEditItemType?
    
    let singleTapGesture = UITapGestureRecognizer()
    
    let editContentView = UIView()
    let contentScrollView = UIScrollView()
    let contentImageView = UIImageView()
    let topToolBar = PhotoEditTopToolBar()
    let bottomToolBar: PhotoEditBottomToolBar
    
    var graffitiDrawColor: UIColor = .clear
    let graffitiDrawLayer = CALayer()
    let graffitiDrawGesture = UIPanGestureRecognizer()
    var graffitiDrawPath = PhotoEditGraffitiPath()
    
    var mosaicMaskImage: UIImage?
    var mosaicDrawLayer = CALayer()
    var mosaicDrawMaskLayer = CAShapeLayer()
    let mosaicDrawGesture = UIPanGestureRecognizer()
    var mosaicDrawPath = PhotoEditMosaicPath()
    
    let maskLayerContentView = UIView()
    let masksTapGesture = UITapGestureRecognizer()
    let masksPanGesture = UIPanGestureRecognizer()
    let masksPinchGesture = UIPinchGestureRecognizer()
    let masksRotationGesture = UIRotationGestureRecognizer()
    let masksTrashCanView = PhotoEditMaskTrashCanView()
    var hasHighlightMasksTrashCanView: Bool = false
    
    var currentFilterImage: UIImage?
    var currentFilter: PhotoEditFilterProvider?
    
    var imageBeforeAdjust: UIImage?
    var currentAdjustMode: PhotoEditAdjustMode?
    var adjustValue: [PhotoEditAdjustMode: Double] = [:]
    let adjustSlideView = PhotoEditAdjustSlideView()
    
    public override var prefersStatusBarHidden: Bool {
        true
    }
    
    init(assetModel: AssetModel?, photoEditConfig: PhotoEditConfig) {
        self.photo = assetModel?.previewImage
        self.assetModel = assetModel
        self.photoEditConfig = photoEditConfig
        self.bottomToolBar = PhotoEditBottomToolBar(photo: assetModel?.previewImage, photoEditConfig: photoEditConfig)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    init(photo: UIImage?, photoEditConfig: PhotoEditConfig) {
        self.photo = photo
        self.assetModel = nil
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
        setupPhoto()
        setupEditedImage()
    }
    
    func setupView() {
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
        
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.isUserInteractionEnabled = true
        contentScrollView.addSubview(contentImageView)
        
        contentImageView.layer.addSublayer(graffitiDrawLayer)
        
        mosaicDrawMaskLayer.strokeColor = UIColor.black.cgColor
        mosaicDrawMaskLayer.fillColor = nil
        mosaicDrawMaskLayer.lineCap = .round
        mosaicDrawMaskLayer.lineJoin = .round
        mosaicDrawLayer.mask = mosaicDrawMaskLayer
        contentImageView.layer.insertSublayer(mosaicDrawLayer, at: 0)
        
        maskLayerContentView.layer.masksToBounds = true
        contentImageView.addSubview(maskLayerContentView)
        
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
    
    func setupPhoto() {
        contentImageView.image = assetModel?.editedImage ?? assetModel?.previewImage ?? photo
        
        guard let photo = self.photo else { return }
        contentImageView.frame = AssetSizeHelper.imageViewRectFrom(imageSize: photo.size, mediaType: .photo)
        graffitiDrawLayer.frame = contentImageView.bounds
        mosaicDrawLayer.frame = contentImageView.bounds
        maskLayerContentView.frame = contentImageView.bounds
        
        contentScrollView.contentSize = contentImageView.frame.size
        contentScrollView.maximumZoomScale = AssetSizeHelper.imageViewMaxZoomScaleFrom(imageSize: photo.size)
        
        graffitiDrawPath.imageSize = photo.size
        graffitiDrawPath.shapeSize = contentImageView.size
        
        mosaicDrawPath.shapeSize = contentImageView.size
        
        currentFilterImage = photo
        
        photoEditConfig.photoEditAdjustModes.forEach {
            adjustValue[$0] = 0
        }
    }
    
    func setupEditedImage() {
        guard let assetModel = self.assetModel, assetModel.hasEdit else { return }
        graffitiDrawPath = assetModel.editGraffitiPath
        currentFilter = assetModel.filter
        adjustValue = assetModel.adjustValue
        mosaicDrawPath = assetModel.editMosaicPath
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let filterImage = self.currentFilter?.filterImage(self.photo) ?? self.photo
            let adjustedImage = filterImage?.adjustImageFrom(self.adjustValue)
            let mosaicMaskImage = adjustedImage?.mosaicImage(level: self.photoEditConfig.photoEditMosaicWidth)
            let image = self.mosaicDrawPath.drawMosaicImage(from: adjustedImage, mosaicImage: mosaicMaskImage)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for maskLayer in assetModel.maskLayers {
                    let maskView = PhotoEditMaskView(maskLayer: maskLayer)
                    maskView.updateMaskLayer(showActive: false)
                    self.maskLayerContentView.addSubview(maskView)
                }
                self.graffitiDrawLayer.contents = self.graffitiDrawPath.draw()?.cgImage
                self.graffitiDrawLayer.removeAllAnimations()
                self.contentImageView.image = image
            }
        }
    }
    
    @objc func contentViewSingleTap() {
        dismissAllMaskActive()
        setToolBarsHidden(bottomToolBar.alpha == 1)
    }
    
    func setToolBarsHidden(_ isHidden: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.topToolBar.alpha = isHidden ? 0 : 1
            self.bottomToolBar.alpha = isHidden ? 0 : 1
            self.adjustSlideView.alpha = isHidden ? 0 : 1
        }
    }
    
}

// MARK: Graffiti
extension PhotoEditViewController {
    
    @objc func graffitiDraw(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: contentImageView)
        let zoomScale = contentScrollView.zoomScale
        switch gesture.state {
        case .began:
            let lineWidth = photoEditConfig.photoEditGraffitiLineWidth / zoomScale
            let pathLine = PhotoEditGraffitiPathLine(graffitiColor: graffitiDrawColor,
                                                     lineWidth: lineWidth,
                                                     startPoint: location)
            graffitiDrawPath.append(pathLine: pathLine)
            setToolBarsHidden(true)
        case .changed:
            graffitiDrawPath.last?.addLine(to: location)
            graffitiDrawLayer.contents = graffitiDrawPath.draw()?.cgImage
        default:
            setToolBarsHidden(false)
        }
    }
    
}

// MARK: Mosaic
extension PhotoEditViewController {
    
    func prepareForMosaic() {
        let adjustedImage = currentFilterImage?.adjustImageFrom(adjustValue)
        mosaicMaskImage = adjustedImage?.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        mosaicDrawLayer.contents = mosaicMaskImage?.cgImage
    }
    
    func drawMosaicImage()  {
        let adjustImage = currentFilterImage?.adjustImageFrom(adjustValue)
        contentImageView.image = mosaicDrawPath.drawMosaicImage(from: adjustImage, mosaicImage: mosaicMaskImage)
    }
    
    @objc func mosaicDraw(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: contentImageView)
        let zoomScale = contentScrollView.zoomScale
        switch gesture.state {
        case .began:
            let lineWidth = photoEditConfig.photoEditMosaicLineWidth / zoomScale
            mosaicDrawMaskLayer.lineWidth = lineWidth
            mosaicDrawMaskLayer.removeAllAnimations()
            let pathLine = PhotoEditMosaicPathLine(lineWidth: lineWidth,
                                                   startPoint: location)
            mosaicDrawPath.append(pathLine: pathLine)
            setToolBarsHidden(true)
        case .changed:
            mosaicDrawPath.last?.addLine(to: location)
            mosaicDrawMaskLayer.path = mosaicDrawPath.last?.drawPath()
        default:
            mosaicDrawMaskLayer.path = nil
            setToolBarsHidden(false)
            drawMosaicImage()
        }
    }
    
}

// MARK: MaskLayer
extension PhotoEditViewController {
    
    func showEditTextController(textMaskLayer: PhotoEditTextMaskLayer?) {
        let backgroundImage = editContentView.screenShot()
        let vc = PhotoEditTextViewController(backgroundImage: backgroundImage,
                                             textMaskLayer: textMaskLayer,
                                             photoEditConfig: photoEditConfig)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func addMaskLayer(maskLayer: PhotoEditMaskLayer) {
        let viewCenter = CGPoint(x: UIScreen.width * 0.5, y: UIScreen.height * 0.5)
        maskLayer.center = view.convert(viewCenter, to: contentImageView)
        let maskView = PhotoEditMaskView(maskLayer: maskLayer)
        maskLayerContentView.addSubview(maskView)
        dismissAllMaskActive()
        maskView.updateMaskLayer()
    }
    
    func maskViewAt(_ location: CGPoint) -> PhotoEditMaskView? {
        return maskLayerContentView.subviews.last(where: { $0.frame.contains(location) }) as? PhotoEditMaskView
    }
    
    func activeMaskView() -> PhotoEditMaskView? {
        return maskLayerContentView.subviews.first(where: { ($0 as? PhotoEditMaskView)?.isActive ?? false }) as? PhotoEditMaskView
    }
    
    func showMaskActiveAt(_ location: CGPoint) {
        guard let maskView = maskViewAt(location) else {
            return
        }
        dismissAllMaskActive()
        maskView.showActive()
        maskLayerContentView.bringSubviewToFront(maskView)
    }
    
    func dismissAllMaskActive() {
        maskLayerContentView.subviews.forEach {
            ($0 as? PhotoEditMaskView)?.dismissActive()
        }
    }
    
    func maskGestureBeginAt(_ location: CGPoint) {
        hasHighlightMasksTrashCanView = false
        setTrashCanViweHidden(false, animated: true)
        setToolBarsHidden(true)
        maskLayerContentView.layer.masksToBounds = false
        showMaskActiveAt(location)
    }
    
    func setTrashCanViweHidden(_ isHidden: Bool, animated: Bool) {
        masksTrashCanView.isHidden = isHidden
        UIView.animate(withDuration: animated ? 0.15 : 0) {
            self.masksTrashCanView.snp.updateConstraints { make in
                make.bottom.equalTo(isHidden ? 0 : (-keyWindowSafeAreaInsets.bottom - 10))
            }
            self.masksTrashCanView.alpha = isHidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleMasksTapGesture(_ gesture: UITapGestureRecognizer) {
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
    
    @objc func handleMasksPanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: maskLayerContentView)
        switch gesture.state {
        case .began:
            maskGestureBeginAt(location)
        case .changed:
            guard let maskView = activeMaskView() else { return }
            let translation = gesture.translation(in: maskLayerContentView)
            maskView.maskLayer.translation = CGPoint(x: maskView.maskLayer.translation.x + translation.x,
                                                     y: maskView.maskLayer.translation.y + translation.y)
            gesture.setTranslation(.zero, in: maskLayerContentView)
            maskView.updateMaskLayer(dismissLater: false)
            let viewLocation = maskLayerContentView.convert(location, to: self.view)
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
            if maskLayerContentView.frame.contains(location) {
                maskLayerContentView.layer.masksToBounds = true
                maskView.showActive()
            } else {
                maskView.maskLayer.translation = .zero
                maskView.updateMaskLayer(animate: true) {
                    self.maskLayerContentView.layer.masksToBounds = true
                }
            }
        default:
            break
        }
    }
    
    @objc func handleMasksPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: maskLayerContentView)
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
            if maskLayerContentView.frame.contains(location) {
                maskLayerContentView.layer.masksToBounds = true
            }
        default:
            break
        }
    }
    
    @objc func handleMasksRotationGesture(_ gesture: UIRotationGestureRecognizer) {
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
            if maskLayerContentView.frame.contains(location) {
                maskLayerContentView.layer.masksToBounds = true
            }
        default:
            break
        }
    }
    
}

// MARK: Filter
extension PhotoEditViewController {
    
    func drawFilterImage(filter: PhotoEditFilterProvider) {
        currentFilter = filter
        currentFilterImage = filter.filterImage(photo)
        let filterMosaicImage = currentFilterImage?.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        let mosaicImage = mosaicDrawPath.drawMosaicImage(from: currentFilterImage,
                                                         mosaicImage: filterMosaicImage)
        contentImageView.image = mosaicImage?.adjustImageFrom(adjustValue)
    }
    
}

// MARK: Adjust
extension PhotoEditViewController {
    
    @objc func adjustSlideValueChange() {
        let value = adjustSlideView.value
        changeAdjustValue(value)
    }
    
    func prepareForAdjust() {
        let mosaicImage = currentFilterImage?.mosaicImage(level: photoEditConfig.photoEditMosaicWidth)
        imageBeforeAdjust = mosaicDrawPath.drawMosaicImage(from: currentFilterImage,
                                                           mosaicImage: mosaicImage)
    }
    
    func changeAdjustValue(_ value: Double) {
        guard let currentAdjustMode = self.currentAdjustMode  else {
            return
        }
        adjustValue[currentAdjustMode] = value
        contentImageView.image = imageBeforeAdjust?.adjustImageFrom(adjustValue)
    }
    
}

// MARK: UIScrollViewDelegate
extension PhotoEditViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentImageView.center = AssetSizeHelper.imageViewCenterWhenZoom(scrollView)
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
        if itemType?.hasNextStep ?? true {
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
//            let maskLayers = maskLayerContentView.subviews.compactMap{
//                ($0 as? PhotoEditMaskView)?.maskLayer
//            }
//            let image = EditManager.drawMasksAt(photo: contentImageView.image, with: graffitiDrawPath, maskLayers: maskLayers)
//            guard let editedImage = image else { return }
//            let vc = PhotoEditCropViewController(photo: editedImage, assetModel: assetModel)
//            present(vc, animated: true, completion: nil)
            break
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
        graffitiDrawPath.removeLast()
        graffitiDrawLayer.contents = graffitiDrawPath.draw()?.cgImage
        graffitiDrawLayer.removeAllAnimations()
    }
    
    func bottomToolBarDidClickMosaicUndoButton(_ bottomToolBar: PhotoEditBottomToolBar) {
        mosaicDrawPath.removeLast()
        drawMosaicImage()
    }
    
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectFilter filter: PhotoEditFilterProvider) {
        drawFilterImage(filter: filter)
    }
    
    func bottomToolBar(_ bottomToolBar: PhotoEditBottomToolBar, didSelectAdjustMode adjustMode: PhotoEditAdjustMode) {
        adjustSlideView.minimumValue = adjustMode.minimumValue
        currentAdjustMode = adjustMode
        if let value = adjustValue[adjustMode] {
            adjustSlideView.value = value
        }
    }
    
    func bottomToolBarDidClickDoneButton(_ bottomToolBar: PhotoEditBottomToolBar) {
        let maskLayers = maskLayerContentView.subviews.compactMap{
            ($0 as? PhotoEditMaskView)?.maskLayer
        }
        if let assetModel = self.assetModel {
            assetModel.editMosaicPath = mosaicDrawPath
            assetModel.editGraffitiPath = graffitiDrawPath
            assetModel.maskLayers = maskLayers
            assetModel.filter = currentFilter
            assetModel.adjustValue = adjustValue
            assetModel.editedImage = EditManager.drawMasksAt(photo: contentImageView.image, with: assetModel)
            delegate?.editController(self, didDidFinishEditAsset: assetModel)
        } else {
            let editedImage = EditManager.drawMasksAt(photo: contentImageView.image,
                                                      editGraffitiPath: graffitiDrawPath,
                                                      maskLayers: maskLayers)
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
        maskLayerContentView.subviews.compactMap {
            $0 as? PhotoEditMaskView
        }.first(where:  {
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

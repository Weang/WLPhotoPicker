//
//  PhotoEditCropViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

protocol PhotoEditCropViewControllerDelegate: AnyObject {
    
    func cropViewController(_ viewController: PhotoEditCropViewController, didFinishCrop image: UIImage, cropRect: PhotoEditCropRect, rotation: UIImage.Orientation)
    
}

class PhotoEditCropViewController: UIViewController {
    
    weak var delegate: PhotoEditCropViewControllerDelegate?
    
    let photoEditCropRatios: PhotoEditCropRatio
    var cropRect: PhotoEditCropRect = .identity
    var cropRotation: UIImage.Orientation = .up
    
    let photo: UIImage
    var currentPhoto: UIImage
    var cropedImage: UIImage?
    
    let contentScrollView = UIScrollView()
    let contentImageView = UIImageView()
    let cropRectangleView: PhotoEditCropRectangleView
    let bottomToolBar = PhotoEditCropToolBar()
    
    var currentImageViewsize: CGSize = .zero
    let originalContentInset = UIEdgeInsets(top: keyWindowSafeAreaInsets.top + 20, left: 12, bottom: 20, right: 12)
    var maximumCropRect: CGRect {
        return CGRect(x: originalContentInset.left,
                      y: originalContentInset.top,
                      width: contentScrollView.width - originalContentInset.left - originalContentInset.right,
                      height: contentScrollView.height - originalContentInset.top - originalContentInset.bottom)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(photo: UIImage, cropRect: PhotoEditCropRect = .identity, cropRotation: UIImage.Orientation = .up, photoEditCropRatios: PhotoEditCropRatio = .freedom) {
        self.photo = photo
        self.currentPhoto = photo
        self.cropRect = cropRect
        self.cropRotation = cropRotation
        self.photoEditCropRatios = photoEditCropRatios
        self.cropRectangleView = PhotoEditCropRectangleView(photoEditCropRatios: photoEditCropRatios)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupEditedImage()
    }
    
    func setupView() {
        view.backgroundColor = .black
        view.clipsToBounds = true
        
        bottomToolBar.delegate = self
        view.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        contentScrollView.decelerationRate = .fast
        contentScrollView.backgroundColor = .clear
        contentScrollView.delegate = self
        contentScrollView.minimumZoomScale = 1
        contentScrollView.maximumZoomScale = 20
        contentScrollView.zoomScale = 1
        contentScrollView.contentInsetAdjustmentBehavior = .never
        contentScrollView.clipsToBounds = false
        contentScrollView.alwaysBounceHorizontal = true
        contentScrollView.alwaysBounceVertical = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bottomToolBar.snp.top)
        }
        
        contentImageView.image = photo
        contentScrollView.addSubview(contentImageView)
        
        cropRectangleView.delegate = self
        view.addSubview(cropRectangleView)
        cropRectangleView.snp.makeConstraints { make in
            make.edges.equalTo(contentScrollView)
        }
        
        view.bringSubviewToFront(bottomToolBar)
        view.layoutIfNeeded()
        
        let displayRect = adaptionDisplayRect(displaySize: photo.size)
        let contentInset = scrollViewContentInsetFrom(displayRect: displayRect)
        
        contentScrollView.zoomScale = 1
        
        contentImageView.frame = CGRect(origin: .zero, size: displayRect.size)
        currentImageViewsize = contentImageView.size
        
        contentScrollView.contentSize = contentImageView.size
        contentScrollView.contentInset = contentInset
        
        cropRectangleView.updateCropRect(displayRect, animate: false)
        fitMaximumCropRect()
    }
    
    func setupEditedImage() {
        guard cropRect != .identity || cropRotation != .up else { return }
        
        currentPhoto = currentPhoto.rotate(orientation: cropRotation)
        cropedImage = currentPhoto.cropToRect(cropRect)

        let toDisplayImageRect = adaptionDisplayRect(displaySize: currentPhoto.size)
        currentImageViewsize = toDisplayImageRect.size
        contentScrollView.minimumZoomScale = 1
        contentScrollView.zoomScale = 1
        contentScrollView.contentSize = currentImageViewsize
        contentImageView.image = currentPhoto
        contentImageView.transform = .identity
        contentImageView.frame = CGRect(origin: .zero, size: currentImageViewsize)

        let cropImageRect = CGRect(x: cropRect.x * contentImageView.width,
                                   y: cropRect.y * contentImageView.height,
                                   width: cropRect.width * contentImageView.width,
                                   height: cropRect.height * contentImageView.height)
        cropToImageRect(cropImageRect, animate: false)
    }
    
    func adaptionDisplayRect(displaySize: CGSize) -> CGRect {
        let viewWidth = contentScrollView.width - originalContentInset.left - originalContentInset.right
        let viewHeight = contentScrollView.height - originalContentInset.top - originalContentInset.bottom
        let viewRatio = viewWidth / viewHeight
        
        let displayRatio = displaySize.width / displaySize.height
        
        var displayRect: CGRect = .zero
        
        if displayRatio > viewRatio {
            displayRect.size.width = viewWidth
            displayRect.size.height = viewWidth / displayRatio
            displayRect.origin.x = originalContentInset.left
            displayRect.origin.y = (viewHeight - displayRect.size.height) * 0.5 + originalContentInset.top
        } else {
            displayRect.size.height = viewHeight
            displayRect.size.width = viewHeight * displayRatio
            displayRect.origin.y = originalContentInset.top
            displayRect.origin.x = (viewWidth - displayRect.size.width) * 0.5 + originalContentInset.left
        }
        
        return displayRect
    }
    
    func fitMaximumCropRect() {
        let imageViweFrame = contentScrollView.convert(contentImageView.frame, to: cropRectangleView)
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        if imageViweFrame.origin.x < originalContentInset.left {
            x = originalContentInset.left
        } else {
            x = imageViweFrame.origin.x
        }
        if imageViweFrame.origin.y < originalContentInset.top {
            y = originalContentInset.top
        } else {
            y = imageViweFrame.origin.y
        }
        if cropRectangleView.width - (imageViweFrame.size.width + imageViweFrame.origin.x) < originalContentInset.right {
            width = cropRectangleView.width - originalContentInset.right - cropRectangleView.cropRect.origin.x
        } else {
            width = imageViweFrame.size.width + imageViweFrame.origin.x - cropRectangleView.cropRect.origin.x
        }
        if cropRectangleView.height - (imageViweFrame.size.height + imageViweFrame.origin.y) < originalContentInset.bottom {
            height = cropRectangleView.height - originalContentInset.bottom - cropRectangleView.cropRect.origin.y
        } else {
            height = imageViweFrame.size.height + imageViweFrame.origin.y - cropRectangleView.cropRect.origin.y
        }
        cropRectangleView.maximumCropRect = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func cropToImageRect(_ cropImageRect: CGRect, animate: Bool) {
        let displayRect = adaptionDisplayRect(displaySize: cropImageRect.size)
        let contentInset = scrollViewContentInsetFrom(displayRect: displayRect)
        var scale = min(displayRect.size.width / cropImageRect.size.width,
                        displayRect.size.height / cropImageRect.size.height)
        if scale < contentScrollView.minimumZoomScale {
            scale = contentScrollView.minimumZoomScale
        }
        if scale > contentScrollView.maximumZoomScale {
            scale = contentScrollView.maximumZoomScale
        }
        UIView.animate(withDuration: animate ? 0.4 : 0.01) {
            self.cropRectangleView.updateCropRect(displayRect, animate: animate)
            self.contentScrollView.zoomScale = scale
            if scale < self.contentScrollView.maximumZoomScale {
                self.contentScrollView.contentOffset.x = cropImageRect.origin.x * scale - contentInset.left
                self.contentScrollView.contentOffset.y = cropImageRect.origin.y * scale - contentInset.top
            }
            self.contentScrollView.contentInset = contentInset
            self.contentImageView.frame.origin = .zero
        } completion: { _ in
            self.contentScrollView.minimumZoomScale = max(displayRect.size.width / self.currentImageViewsize.width,
                                                          displayRect.size.height / self.currentImageViewsize.height)
            self.fitMaximumCropRect()
            self.bottomToolBar.isEnabled = true
        }
    }
    
    func scrollViewContentInsetFrom(displayRect: CGRect) -> UIEdgeInsets {
        return UIEdgeInsets(top: displayRect.origin.y,
                            left: displayRect.origin.x,
                            bottom: contentScrollView.height - displayRect.maxY,
                            right: contentScrollView.width - displayRect.maxX)
    }
    
    func rotateImage(orientation: PhotoEditCropOrientation) {
        currentPhoto = currentPhoto.rotate(orientation: orientation.imageOrientation)
        
        let fromImageViewSize = view.convert(contentImageView.frame, to: contentImageView).size
        let fromCropImageRect = view.convert(cropRectangleView.cropRect, to: contentImageView)
        
        let toDisplayImageRect = adaptionDisplayRect(displaySize: currentPhoto.size)
        let toImageViewSize = toDisplayImageRect.size
        let toCropImageRect: CGRect
        switch orientation {
        case .left:
            toCropImageRect = CGRect(x: (fromCropImageRect.minY / fromImageViewSize.height) * toImageViewSize.width,
                                     y: (fromImageViewSize.width - fromCropImageRect.maxX) / fromImageViewSize.width * toImageViewSize.height,
                                     width: (fromCropImageRect.height / fromImageViewSize.height) * toImageViewSize.width,
                                     height: (fromCropImageRect.width / fromImageViewSize.width) * toImageViewSize.height)
        case .right:
            toCropImageRect = CGRect(x: (fromImageViewSize.height - fromCropImageRect.maxY) / fromImageViewSize.height * toImageViewSize.width,
                                     y: (fromCropImageRect.minX / fromImageViewSize.width) * toImageViewSize.height,
                                     width: (fromCropImageRect.height / fromImageViewSize.height) * toImageViewSize.width,
                                     height: (fromCropImageRect.width / fromImageViewSize.width) * toImageViewSize.height)
        }
        
        if let image = contentImageView.screenShot(rect: fromCropImageRect) {
            let toImageSize = CGSize(width: image.size.height, height: image.size.width)
            let toCropRect = adaptionDisplayRect(displaySize: toImageSize)
            
            let transformScale: CGFloat
            if cropRectangleView.cropRect.size.width > cropRectangleView.cropRect.size.height {
                transformScale = toCropRect.size.height / cropRectangleView.cropRect.size.width
            } else {
                transformScale = toCropRect.size.width / cropRectangleView.cropRect.size.height
            }
            let animateBackgroundView = UIView()
            animateBackgroundView.backgroundColor = .black
            animateBackgroundView.frame = view.bounds
            view.addSubview(animateBackgroundView)
            
            let animateImageView = UIImageView()
            animateImageView.image = image
            animateImageView.frame = view.convert(cropRectangleView.cropRect, to: animateBackgroundView)
            animateBackgroundView.addSubview(animateImageView)
            
            let rotationAngle: CGFloat
            switch orientation {
            case .left:
                rotationAngle = -CGFloat.pi / 2
                cropRotation = cropRotation.rotateLeft()
            case .right:
                rotationAngle = CGFloat.pi / 2
                cropRotation = cropRotation.rotateRight()
            }
            
            UIView.animate(withDuration: 0.3) {
                animateImageView.transform = CGAffineTransform(rotationAngle: rotationAngle).scaledBy(x: transformScale, y: transformScale)
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseOut) {
                animateBackgroundView.alpha = 0
            } completion: { _ in
                animateBackgroundView.removeFromSuperview()
            }
        }
        
        currentImageViewsize = toImageViewSize
        contentScrollView.minimumZoomScale = 1
        contentScrollView.zoomScale = 1
        contentScrollView.contentSize = toImageViewSize
        contentImageView.image = currentPhoto
        contentImageView.transform = .identity
        contentImageView.frame = CGRect(origin: .zero, size: toImageViewSize)
        
        cropToImageRect(toCropImageRect, animate: false)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEditCropViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cropRectangleView.hideCover()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fitMaximumCropRect()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            cropRectangleView.showCoverWithDelay()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropRectangleView.showCoverWithDelay()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        cropRectangleView.hideCover()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentImageView.center = AssetSizeHelper.imageViewCenterWhenZoom(scrollView)
        fitMaximumCropRect()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cropRectangleView.showCoverWithDelay()
    }
}

extension PhotoEditCropViewController: PhotoEditCropToolBarDelegate {
    func toolBarDidClickCancelButton(_ toolBar: PhotoEditCropToolBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func toolBarDidClickRotateLeftButton(_ toolBar: PhotoEditCropToolBar) {
        rotateImage(orientation: .left)
    }
    
    func toolBarDidClickResetButton(_ toolBar: PhotoEditCropToolBar) {
        contentScrollView.minimumZoomScale = 1
        cropToImageRect(contentImageView.bounds, animate: true)
    }
    
    func toolBarDidClickRotateRightButton(_ toolBar: PhotoEditCropToolBar) {
        rotateImage(orientation: .right)
    }
    
    func toolBarDidClickDoneButton(_ toolBar: PhotoEditCropToolBar) {
        let imageViewSize = view.convert(contentImageView.frame, to: contentImageView).size
        let cropImageViewRect = view.convert(cropRectangleView.cropRect, to: contentImageView)
        let cropImageRect = PhotoEditCropRect(x: cropImageViewRect.minX / imageViewSize.width,
                                              y: cropImageViewRect.minY / imageViewSize.height,
                                              width: cropImageViewRect.width / imageViewSize.width,
                                              height: cropImageViewRect.height / imageViewSize.height)
        let image = currentPhoto.cropToRect(cropImageRect)
        cropedImage = image
        delegate?.cropViewController(self, didFinishCrop: image, cropRect: cropImageRect, rotation: cropRotation)
        dismiss(animated: true, completion: nil)
    }
    
}

extension PhotoEditCropViewController: PhotoEditCropRectangleViewDelegate {
    
    func cropViewDidBeginDrag(_ cropView: PhotoEditCropRectangleView) {
        bottomToolBar.isEnabled = false
    }
    
    func cropView(_ cropView: PhotoEditCropRectangleView, willCropToRect cropRect: CGRect) {
        contentScrollView.contentInset = scrollViewContentInsetFrom(displayRect: cropRect)
    }
    
    func cropView(_ cropView: PhotoEditCropRectangleView, didCropToRect cropRect: CGRect) {
        let imageCropRect = cropView.convert(cropRect, to: contentImageView)
        cropToImageRect(imageCropRect, animate: true)
    }
    
}

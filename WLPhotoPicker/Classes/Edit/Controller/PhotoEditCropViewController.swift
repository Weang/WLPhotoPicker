//
//  PhotoEditCropViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

public protocol PhotoEditCropViewControllerDelegate: AnyObject {
    
    func cropViewController(_ viewController: PhotoEditCropViewController, didFinishCrop image: UIImage, cropRect: PhotoEditCropRect, rotation: UIImage.Orientation)
    
}

public class PhotoEditCropViewController: UIViewController {
    
    public weak var delegate: PhotoEditCropViewControllerDelegate?
    
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
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public convenience init(photo: UIImage, photoEditCropRatios: PhotoEditCropRatio = .freedom) {
        self.init(photo: photo, cropRect: .identity, cropRotation: .up, photoEditCropRatios: photoEditCropRatios)
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        if cropRect != .identity || cropRotation != .up  {
            setupEditedImage()
        } else if photoEditCropRatios != .freedom {
            setupCropRatio(animate: false)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        
        let displayRect = adjustDisplayRect(photo.size)
        let contentInset = fitContentInset(displayRect)
        
        contentScrollView.zoomScale = 1
        
        contentImageView.frame = CGRect(origin: .zero, size: displayRect.size)
        currentImageViewsize = contentImageView.size
        
        contentScrollView.contentSize = contentImageView.size
        contentScrollView.contentInset = contentInset
        
        cropRectangleView.updateCropRect(displayRect, animate: false)
        fitMaximumCropRect()
    }
    
    func setupEditedImage() {
        currentPhoto = currentPhoto.rotate(orientation: cropRotation)
        cropedImage = currentPhoto.cropToRect(cropRect)

        let toDisplayImageRect = adjustDisplayRect(currentPhoto.size)
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
    
    func setupCropRatio(animate: Bool) {
        let ratio = photoEditCropRatios.ratio
        let imageViewSize = view.convert(contentImageView.frame, to: contentImageView).size
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        var cropRect: CGRect = .zero
        if imageViewRatio > ratio {
            cropRect.size.height = imageViewSize.height
            cropRect.size.width = imageViewSize.height * ratio
            cropRect.origin.y = 0
            cropRect.origin.x = (imageViewSize.width - cropRect.width) * 0.5
        } else {
            cropRect.size.width = imageViewSize.width
            cropRect.size.height = imageViewSize.width / ratio
            cropRect.origin.x = 0
            cropRect.origin.y = (imageViewSize.height - cropRect.height) * 0.5
        }
        cropToImageRect(cropRect, animate: animate)
    }
    
    func adjustDisplayRect(_ imageSize: CGSize) -> CGRect {
        let viewWidth = contentScrollView.width - originalContentInset.left - originalContentInset.right
        let viewHeight = contentScrollView.height - originalContentInset.top - originalContentInset.bottom
        let viewRatio = viewWidth / viewHeight
        
        let displayRatio = imageSize.width / imageSize.height
        
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
        displayRect = displayRect.rounded()
        return displayRect
    }
    func fitMaximumCropRect() {
        let imageViweFrame = contentScrollView.convert(contentImageView.frame, to: cropRectangleView)
        
        var maximumCropRect: CGRect = .zero
        maximumCropRect.origin.x = max(imageViweFrame.origin.x, originalContentInset.left)
        maximumCropRect.origin.y = max(imageViweFrame.origin.y, originalContentInset.top)
        
        if cropRectangleView.width - (imageViweFrame.size.width + imageViweFrame.origin.x) < originalContentInset.right {
            maximumCropRect.size.width = cropRectangleView.width - originalContentInset.right - cropRectangleView.cropRect.origin.x
        } else {
            maximumCropRect.size.width = imageViweFrame.size.width + imageViweFrame.origin.x - cropRectangleView.cropRect.origin.x
        }
        
        if cropRectangleView.height - (imageViweFrame.size.height + imageViweFrame.origin.y) < originalContentInset.bottom {
            maximumCropRect.size.height = cropRectangleView.height - originalContentInset.bottom - cropRectangleView.cropRect.origin.y
        } else {
            maximumCropRect.size.height = imageViweFrame.size.height + imageViweFrame.origin.y - cropRectangleView.cropRect.origin.y
        }
        
        cropRectangleView.maximumCropRect = maximumCropRect
    }
    
    func fitContentInset(_ displayRect: CGRect) -> UIEdgeInsets {
        return UIEdgeInsets(top: displayRect.origin.y,
                            left: displayRect.origin.x,
                            bottom: contentScrollView.height - displayRect.maxY,
                            right: contentScrollView.width - displayRect.maxX)
    }
    
    func cropToImageRect(_ cropImageRect: CGRect, animate: Bool) {
        let displayRect = adjustDisplayRect(cropImageRect.size)
        let contentInset = fitContentInset(displayRect)
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
    
    func rotateImage(orientation: PhotoEditCropOrientation) {
        currentPhoto = currentPhoto.rotate(orientation: orientation.imageOrientation)
        
        let fromImageViewSize = view.convert(contentImageView.frame, to: contentImageView).size
        let fromCropImageRect = view.convert(cropRectangleView.cropRect, to: contentImageView)
        
        let toDisplayImageRect = adjustDisplayRect(currentPhoto.size)
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
            let toCropRect = adjustDisplayRect(toImageSize)
            
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
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UIScrollViewDelegate
extension PhotoEditCropViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cropRectangleView.hideCover()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fitMaximumCropRect()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            cropRectangleView.showCoverWithDelay()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropRectangleView.showCoverWithDelay()
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        cropRectangleView.hideCover()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentImageView.center = scrollView.zoomSubviewCenter
        fitMaximumCropRect()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cropRectangleView.showCoverWithDelay()
    }
}

// MARK: PhotoEditCropToolBarDelegate
extension PhotoEditCropViewController: PhotoEditCropToolBarDelegate {
    
    func toolBarDidClickCancelButton(_ toolBar: PhotoEditCropToolBar) {
        if let _ = presentingViewController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func toolBarDidClickRotateLeftButton(_ toolBar: PhotoEditCropToolBar) {
        rotateImage(orientation: .left)
    }
    
    func toolBarDidClickResetButton(_ toolBar: PhotoEditCropToolBar) {
        contentScrollView.minimumZoomScale = 1
        if photoEditCropRatios != .freedom {
            setupCropRatio(animate: true)
        } else {
            cropToImageRect(contentImageView.bounds.rounded(), animate: true)
        }
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
        if let _ = presentingViewController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: PhotoEditCropRectangleViewDelegate
extension PhotoEditCropViewController: PhotoEditCropRectangleViewDelegate {
    
    func cropViewDidBeginDrag(_ cropView: PhotoEditCropRectangleView) {
        bottomToolBar.isEnabled = false
    }
    
    func cropView(_ cropView: PhotoEditCropRectangleView, willCropToRect cropRect: CGRect) {
        contentScrollView.contentInset = fitContentInset(cropRect)
    }
    
    func cropView(_ cropView: PhotoEditCropRectangleView, didCropToRect cropRect: CGRect) {
        let imageCropRect = cropView.convert(cropRect, to: contentImageView)
        cropToImageRect(imageCropRect, animate: true)
    }
    
}

//
//  PhotoEditCropViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

public class PhotoEditCropViewController: UIViewController {
    
    let photo: UIImage
    var currentPhoto: UIImage
    let assetModel: AssetModel?
    
    let contentScrollView = UIScrollView()
    let contentImageView = UIImageView()
    let cropRectangleView = PhotoEditCropRectangleView()
    let bottomToolBar = PhotoEditCropToolBar()
    
    var originalImageViewsize: CGSize = .zero
    let originalContentInset = UIEdgeInsets(top: keyWindowSafeAreaInsets.top + 20, left: 12, bottom: 20, right: 12)
    var maximumCropRect: CGRect {
        return CGRect(x: originalContentInset.left,
                      y: originalContentInset.top,
                      width: contentScrollView.width - originalContentInset.left - originalContentInset.right,
                      height: contentScrollView.height - originalContentInset.top - originalContentInset.bottom)
    }
    
    var rotateAngle: CGFloat = 0
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public init(photo: UIImage, assetModel: AssetModel?) {
        self.photo = photo
        self.currentPhoto = photo
        self.assetModel = assetModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        initializeFrames(animate: false)
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
    }
    
    func initializeFrames(animate: Bool) {
        let displayRect = adaptionDisplay(displaySize: photo.size)
        let contentInset = scrollViewContentInsetFrom(displayRect: displayRect)
        
        contentScrollView.zoomScale = 1
        
        contentImageView.frame = CGRect(origin: .zero, size: displayRect.size)
        originalImageViewsize = contentImageView.size
        
        contentScrollView.contentSize = contentImageView.size
        contentScrollView.contentInset = contentInset
       
        cropRectangleView.updateCropRect(displayRect, animate: animate)
        computeMaximumCropRect()
    }
    
    func adaptionDisplay(displaySize: CGSize) -> CGRect {
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
    
    func scrollViewContentInsetFrom(displayRect: CGRect) -> UIEdgeInsets {
        return UIEdgeInsets(top: displayRect.origin.y,
                            left: displayRect.origin.x,
                            bottom: contentScrollView.height - displayRect.maxY,
                            right: contentScrollView.width - displayRect.maxX)
    }
    
    func computeMaximumCropRect() {
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
        let displayRect = adaptionDisplay(displaySize: cropImageRect.size)
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
            self.contentScrollView.minimumZoomScale = max(displayRect.size.width / self.originalImageViewsize.width,
                                                          displayRect.size.height / self.originalImageViewsize.height)
            self.computeMaximumCropRect()
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEditCropViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cropRectangleView.hideCover()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        computeMaximumCropRect()
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
        contentImageView.center = AssetSizeHelper.imageViewCenterWhenZoom(scrollView)
        computeMaximumCropRect()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cropRectangleView.showCoverWithDelay()
    }
}

extension PhotoEditCropViewController: PhotoEditCropToolBarDelegate {
    
    func toolBarDidClickCancelButton(_ toolBar: PhotoEditCropToolBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func toolBarDidClickRotateLeftButton(_ toolBar: PhotoEditCropToolBar) {
        let cropImageRect = view.convert(cropRectangleView.cropRect, to: contentImageView)
        guard let image = contentImageView.screenShot(rect: cropImageRect) else {
            return
        }
        
        let fromImageRect = contentImageView.frame
        let fromCropRect = adaptionDisplay(displaySize: image.size)
        let toImageSize = CGSize(width: image.size.height, height: image.size.width)
        let toCropRect = adaptionDisplay(displaySize: toImageSize)
        
        let transformScale: CGFloat
        if fromCropRect.size.width > fromCropRect.size.height {
            transformScale = toCropRect.size.height / fromCropRect.size.width
        } else {
            transformScale = toCropRect.size.width / fromCropRect.size.height
        }
        let zoomScale = contentScrollView.zoomScale
        
        let contentInset = scrollViewContentInsetFrom(displayRect: toCropRect)
        currentPhoto = currentPhoto.rotate(orientation: .left)
        contentImageView.frame = CGRect(origin: .zero, size: adaptionDisplay(displaySize: currentPhoto.size).size)
        contentImageView.transform = .identity
        contentImageView.image = currentPhoto
        originalImageViewsize = contentImageView.size
        contentScrollView.contentSize = contentImageView.size
        contentScrollView.zoomScale = zoomScale * transformScale
        contentScrollView.contentInset = contentInset
        
//        var toCropImageRect = cropRectangleView.convert(toCropRect, to: contentImageView)
//        toCropImageRect.origin.x = cropImageRect.origin.y
//        toCropImageRect.origin.y = cropImageRect.origin.x
//        let toCropImageRect = CGRect(x: 0,
//                                     y: 0,
//                                     width: cropImageRect.size.height * transformScale,
//                                     height: cropImageRect.size.width * transformScale)
////        cropToImageRect(toCropImageRect, animate: false)
//        cropToImageRect(toCropImageRect, animate: false)
        
        let animateBackgroundView = UIView()
        animateBackgroundView.backgroundColor = .black
        animateBackgroundView.frame = cropRectangleView.frame
        view.addSubview(animateBackgroundView)

        let animateImageView = UIImageView()
        animateImageView.image = image
        animateImageView.frame = fromCropRect
        animateBackgroundView.addSubview(animateImageView)

        UIView.animate(withDuration: 0.3) {
            animateImageView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2).scaledBy(x: transformScale, y: transformScale)
        }

        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseOut) {
            animateBackgroundView.alpha = 0
        } completion: { _ in
            animateBackgroundView.removeFromSuperview()
        }
    }
    
    func toolBarDidClickResetButton(_ toolBar: PhotoEditCropToolBar) {
        contentScrollView.minimumZoomScale = 1
        cropToImageRect(contentImageView.bounds, animate: true)
    }
}

extension PhotoEditCropViewController: PhotoEditCropRectangleViewDelegate {
    
    func cropView(_ cropView: PhotoEditCropRectangleView, willCropToRect cropRect: CGRect) {
        contentScrollView.contentInset = scrollViewContentInsetFrom(displayRect: cropRect)
    }
    
    func cropView(_ cropView: PhotoEditCropRectangleView, didCropToRect cropRect: CGRect) {
        let imageCropRect = cropView.convert(cropRect, to: contentImageView)
        cropToImageRect(imageCropRect, animate: true)
    }
    
}

extension UIImage {
    
    func rotate(orientation: UIImage.Orientation) -> UIImage {
        guard let imagRef = self.cgImage else {
            return self
        }
        
        func swapWidthHeight(_ rect: inout CGRect) {
            (rect.size.width, rect.size.height) = (rect.size.height, rect.size.width)
        }
        
        let rect = CGRect(origin: .zero, size: self.size)
        var bounds = rect
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case .up:
            return self
        case .upMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .down:
            transform = transform.translatedBy(x: rect.width, y: rect.height)
            transform = transform.rotated(by: .pi)
        case .downMirrored:
            transform = transform.translatedBy(x: 0, y: rect.height)
            transform = transform.scaledBy(x: 1, y: -1)
        case .left:
            swapWidthHeight(&bounds)
            transform = transform.translatedBy(x: 0, y: rect.width)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .leftMirrored:
            swapWidthHeight(&bounds)
            transform = transform.translatedBy(x: rect.height, y: rect.width)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .right:
            swapWidthHeight(&bounds)
            transform = transform.translatedBy(x: rect.height, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .rightMirrored:
            swapWidthHeight(&bounds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi / 2)
        @unknown default:
            return self
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.scaleBy(x: -1, y: 1)
            context?.translateBy(x: -rect.height, y: 0)
        default:
            context?.scaleBy(x: 1, y: -1)
            context?.translateBy(x: 0, y: -rect.height)
        }
        context?.concatenate(transform)
        context?.draw(imagRef, in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
}

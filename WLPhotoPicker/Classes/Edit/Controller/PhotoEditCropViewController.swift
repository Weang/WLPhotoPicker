//
//  PhotoEditCropViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

class PhotoEditCropViewController: UIViewController {
    
    let photo: UIImage
    let assetModel: AssetModel
    
    let contentScrollView = UIScrollView()
    let contentImageView = UIImageView()
    let cropRectangleView = PhotoEditCropRectangleView()
    let bottomToolBar = PhotoEditCropToolBar()
    
    var contentScrollViewSize: CGSize {
        CGSize(width: UIScreen.width - 24,
               height: UIScreen.height - bottomToolBar.intrinsicContentSize.height - keyWindowSafeAreaInsets.top - 40)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(photo: UIImage, assetModel: AssetModel) {
        self.photo = photo
        self.assetModel = assetModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .black
        let imageFrame = AssetSizeHelper.cropViewRectFrom(imageSize: photo.size, to: contentScrollViewSize)
        
        bottomToolBar.delegate = self
        view.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        contentScrollView.contentSize = imageFrame.size
        
        contentScrollView.delegate = self
        contentScrollView.minimumZoomScale = 1
        contentScrollView.maximumZoomScale = 20
        contentScrollView.contentInsetAdjustmentBehavior = .never
        contentScrollView.clipsToBounds = false
        contentScrollView.alwaysBounceHorizontal = true
        contentScrollView.alwaysBounceVertical = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(keyWindowSafeAreaInsets.top + 20)
            make.bottom.equalTo(bottomToolBar.snp.top).offset(-20)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
        contentImageView.image = photo
        contentImageView.frame = imageFrame
        contentScrollView.addSubview(contentImageView)
        
        cropRectangleView.delegate = self
        view.addSubview(cropRectangleView)
        cropRectangleView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bottomToolBar.snp.top)
        }
        
        view.bringSubviewToFront(bottomToolBar)
        
        view.layoutIfNeeded()
        
        let cropRect = contentScrollView.convert(imageFrame, to: cropRectangleView)
        updateCropRect(cropRect)
    }
    
    func updateCropRect(_ rect: CGRect) {
        cropRectangleView.updateCropRect(rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEditCropViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        cropRectangleView.setCoverHidden(true)
        contentImageView.center = AssetSizeHelper.imageViewCenterWhenZoom(scrollView)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cropRectangleView.setCoverHidden(false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cropRectangleView.setCoverHidden(true)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            cropRectangleView.setCoverHidden(false)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cropRectangleView.setCoverHidden(false)
    }
    
}

extension PhotoEditCropViewController: PhotoEditCropToolBarDelegate {
    
    func toolBarDidClickCancelButton(_ toolBar: PhotoEditCropToolBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func toolBarDidClickRotateLeftButton(_ toolBar: PhotoEditCropToolBar) {
        
    }
    
}

extension PhotoEditCropViewController: PhotoEditCropRectangleViewDelegate {
    
    func cropView(_ cropView: PhotoEditCropRectangleView, didCropToRect cropRect: CGRect) {
        let imageViewRect = cropView.convert(cropRect, to: contentImageView)
        let imageFrame = AssetSizeHelper.cropViewRectFrom(imageSize: imageViewRect.size, to: contentScrollViewSize)
        let toRect = contentScrollView.convert(imageFrame, to: cropRectangleView)
        //        UIView.animate(withDuration: 0.4) {
        self.contentScrollView.zoom(to: imageViewRect, animated: false)
        self.cropRectangleView.updateCropRect(toRect)
        //        }
        cropRectangleView.setCoverHidden(false)
    }
    
}

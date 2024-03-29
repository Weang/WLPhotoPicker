//
//  AssetPreviewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

protocol AssetPreviewCellDelegate: AnyObject {
    func previewCellDidSingleTap(_ previewCell: AssetPreviewCell)
    func previewCell(_ previewCell: AssetPreviewCell, shouldShowToolbar isShow: Bool)
    
    func previewCellDidBeginPan(_ previewCell: AssetPreviewCell)
    func previewCell(_ previewCell: AssetPreviewCell, didPanScale scale: CGFloat)
    func previewCell(_ previewCell: AssetPreviewCell, didFinishPanDismiss dismiss: Bool)
}

class AssetPreviewCell: UICollectionViewCell {
    
    weak var delegate: AssetPreviewCellDelegate?
    
    let activityIndicator = UIActivityIndicatorView(style: .white)
    let assetImageView = UIImageView()
    let contentScrollView = UIScrollView()
    
    var model: AssetModel?
    var assetRequest: AssetFetchRequest?
    
    let singleTapGesture = UITapGestureRecognizer()
    let doubleTapGesture = UITapGestureRecognizer()
    let dismissPanGesture = UIPanGestureRecognizer()
    
    var isShowToolBar: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupGesture()
    }
    
    func setupView() {
        contentView.backgroundColor = .clear
        
        contentScrollView.contentInsetAdjustmentBehavior = .never
        contentScrollView.clipsToBounds = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.isUserInteractionEnabled = true
        contentScrollView.delegate = self
        contentScrollView.setZoomScale(1.0, animated: false)
        contentScrollView.minimumZoomScale = 1
        contentScrollView.bouncesZoom = true
        contentView.addSubview(contentScrollView)
        
        assetImageView.isUserInteractionEnabled = false
        assetImageView.contentMode = .scaleAspectFit
        contentScrollView.addSubview(assetImageView)
        
        activityIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupGesture() {
        singleTapGesture.addTarget(self, action: #selector(handleSingleTapGesture))
        contentScrollView.addGestureRecognizer(singleTapGesture)
        
        doubleTapGesture.addTarget(self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        contentScrollView.addGestureRecognizer(doubleTapGesture)
        
        dismissPanGesture.delegate = self
        dismissPanGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        contentScrollView.addGestureRecognizer(dismissPanGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    // MARK: Set Data & Request
    func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        self.model = model
        
        cancelCurrentRequest()
        
        if let image = model.displayingPhoto {
            layoutImage(image)
        } else {
            layoutImage(thumbnail)
            requestImage(model, pickerConfig: pickerConfig)
        }
    }
    
    func cancelCurrentRequest() {
        assetRequest?.cancel()
        assetRequest = nil
        layoutImage(nil)
    }
    
    func requestImage(_ model: AssetModel, pickerConfig: PickerConfig) {
        let options = AssetFetchOptions()
        options.sizeOption = .specify(pickerConfig.maximumPreviewSize)
        options.imageDeliveryMode = .highQualityFormat
        
        activityIndicator.startAnimating()
        
        assetRequest = AssetFetchTool.requestPhoto(for: model.asset, options: options) { [weak self] result, _ in
            self?.activityIndicator.stopAnimating()
            if case .success(let response) = result {
                self?.layoutImage(response.photo)
            }
        }
    }
    
    func layoutImage(_ image: UIImage?) {
        contentScrollView.setZoomScale(1, animated: false)
        assetImageView.image = image
        if let image = image {
            assetImageView.frame = AssetDisplayHelper.imageViewRectFrom(imageSize: image.size, mediaType: model?.mediaType ?? .photo)
            contentScrollView.maximumZoomScale = AssetDisplayHelper.imageViewMaxZoomScaleFrom(imageSize: image.size)
            contentScrollView.contentSize = assetImageView.frame.size
        } else {
            contentScrollView.maximumZoomScale = 1
            contentScrollView.contentSize = .zero
            assetImageView.frame = .zero
        }
    }
    
    // MARK: Gesture
    @objc func handleSingleTapGesture() {
        delegate?.previewCellDidSingleTap(self)
    }
    
    @objc func handleDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        if contentScrollView.zoomScale == contentScrollView.minimumZoomScale {
            var scale: CGFloat = 3
            if assetImageView.size.ratio > UIScreen.size.ratio  && assetImageView.width > assetImageView.height {
                scale = UIScreen.height / assetImageView.height
            } else if assetImageView.width < UIScreen.width {
                scale = UIScreen.width / assetImageView.width
            }
            let pointInView = gesture.location(in: assetImageView)
            let width = contentScrollView.width / scale
            let height = contentScrollView.height / scale
            let x = pointInView.x - (width / 2.0)
            let y = pointInView.y - (height / 2.0)
            contentScrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
        } else {
            contentScrollView.setZoomScale(contentScrollView.minimumZoomScale, animated: true)
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginPanGesture()
        case .changed:
            let translation = gesture.translation(in: self)
            changedPanGesture(translation: translation)
        default:
            if contentScrollView.frame.origin.y > 80 || gesture.velocity(in: self).y > 500 || contentScrollView.frame.origin.y < -80 || gesture.velocity(in: self).y < -500 {
                finishPanGesture(dismiss: true)
            } else {
                finishPanGesture(dismiss: false)
            }
        }
    }
    
    func beginPanGesture() {
        delegate?.previewCellDidBeginPan(self)
        activityIndicator.alpha = 0
    }
    
    func changedPanGesture(translation: CGPoint) {
        let scaleTransForm = min(1 - abs(translation.y) / UIScreen.main.bounds.height, 1)
        contentScrollView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            .scaledBy(x: scaleTransForm, y: scaleTransForm)
        let scale = min(1 - abs(translation.y) / UIScreen.main.bounds.height * 2, 1)
        delegate?.previewCell(self, didPanScale: scale)
    }
    
    func finishPanGesture(dismiss: Bool) {
        if dismiss {
            delegate?.previewCell(self, didFinishPanDismiss: true)
        } else {
            activityIndicator.alpha = 1
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, animations: {
                self.contentScrollView.transform = .identity
                self.delegate?.previewCell(self, didFinishPanDismiss: false)
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelCurrentRequest()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentScrollView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancelCurrentRequest()
    }
    
}

extension AssetPreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        assetImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        assetImageView.center = scrollView.zoomSubviewCenter
    }
    
}

extension AssetPreviewCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == dismissPanGesture else {
            return true
        }
        let velocity = dismissPanGesture.velocity(in: self)
        guard abs(velocity.x) < abs(velocity.y) else {
            return false
        }
        if velocity.y > 0 && contentScrollView.contentOffset.y <= 0 {
            return true
        }
        if velocity.y < 0 && contentScrollView.contentOffset.y >= contentScrollView.contentSize.height - contentScrollView.height - 1 {
            return true
        }
        return false
    }
    
}

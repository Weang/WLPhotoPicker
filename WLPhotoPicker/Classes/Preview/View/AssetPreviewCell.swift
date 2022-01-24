//
//  AssetPreviewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

protocol AssetPreviewCellDelegate: AnyObject {
    func previewCellSingleTap(_ previewCell: AssetPreviewCell)
    func previewCellSingleTap(_ previewCell: AssetPreviewCell, shouldShowToolbar isShow: Bool)
    
    func previewCellSingleTapDidBeginPan(_ previewCell: AssetPreviewCell)
    func previewCellSingleTap(_ previewCell: AssetPreviewCell, didPanScale scale: CGFloat)
    func previewCellSingleTap(_ previewCell: AssetPreviewCell, didFinishPanDismiss dismiss: Bool)
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
    let panGesture = UIPanGestureRecognizer()
    
    var isShowToolBar: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        singleTapGesture.addTarget(self, action: #selector(handleSingleTapGesture))
        contentScrollView.addGestureRecognizer(singleTapGesture)
        
        doubleTapGesture.addTarget(self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        contentScrollView.addGestureRecognizer(doubleTapGesture)
        
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        contentScrollView.addGestureRecognizer(panGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        self.model = model
        cancelCurrentRequest()
        
        assetImageView.frame = AssetSizeHelper.imageViewRectFrom(imageSize: model.asset.pixelSize, mediaType: model.mediaType)
        contentScrollView.setZoomScale(1, animated: false)
        contentScrollView.contentSize = assetImageView.frame.size
        contentScrollView.maximumZoomScale = AssetSizeHelper.imageViewMaxZoomScaleFrom(imageSize: model.asset.pixelSize)
        
        requestImage(model, thumbnail: thumbnail, pickerConfig: pickerConfig)
    }
    
    func requestImage(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        if let image = model.displayingImage {
            assetImageView.image = image
            return
        }
        assetImageView.image = thumbnail
        
        let options = AssetFetchOptions()
        options.sizeOption = .specify(pickerConfig.maximumPreviewSize)
        options.imageDeliveryMode = .highQualityFormat
        
        activityIndicator.startAnimating()
        
        assetRequest = AssetFetchTool.requestImage(for: model.asset, options: options) { [weak self] result, _ in
            self?.activityIndicator.stopAnimating()
            if case .success(let response) = result {
                self?.assetImageView.image = response.image
            }
        }
    }
    
    func cellDidScroll() {
        
    }
    
    @objc func handleSingleTapGesture() {
        delegate?.previewCellSingleTap(self)
        print(contentScrollView.frame)
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
            if contentScrollView.frame.origin.y > 80 || gesture.velocity(in: self).y > 500 {
                finishPanGesture(dismiss: true)
            } else {
                finishPanGesture(dismiss: false)
            }
        }
    }
    
    func beginPanGesture() {
        delegate?.previewCellSingleTapDidBeginPan(self)
    }
    
    func changedPanGesture(translation: CGPoint) {
        let transForm = min(1 - translation.y / UIScreen.height, 1)
        contentScrollView.transform = CGAffineTransform(scaleX: transForm, y: transForm)
            .translatedBy(x: translation.x, y: translation.y)
        let scale = min(1 - translation.y / UIScreen.height * 2, 1)
        delegate?.previewCellSingleTap(self, didPanScale: scale)
    }
    
    func finishPanGesture(dismiss: Bool) {
        if dismiss {
            delegate?.previewCellSingleTap(self, didFinishPanDismiss: true)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, animations: {
                self.contentScrollView.transform = .identity
                self.delegate?.previewCellSingleTap(self, didFinishPanDismiss: false)
            })
        }
    }
    
    func cancelCurrentRequest() {
        assetRequest?.cancel()
        assetRequest = nil
        assetImageView.image = nil
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
        assetImageView.center = AssetSizeHelper.imageViewCenterWhenZoom(scrollView)
    }
    
}

extension AssetPreviewCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.panGesture else {
            return true
        }
        let velocity = panGesture.velocity(in: self)
        if velocity.y < 0 || abs(Int(velocity.x)) > Int(velocity.y) || contentScrollView.contentOffset.y > 0 {
            return false
        }
        return true
    }
    
}

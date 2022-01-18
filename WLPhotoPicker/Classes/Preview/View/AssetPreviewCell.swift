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

public class AssetPreviewCell: UICollectionViewCell {
    
    weak var delegate: AssetPreviewCellDelegate?
    
    let iCloudView = AssetPreviewICloudView()
    let assetImageView = UIImageView()
    let contentScrollView = UIScrollView()
    
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
        
        iCloudView.isHidden = true
        contentView.addSubview(iCloudView)
        iCloudView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(100)
        }
        
        singleTapGesture.addTarget(self, action: #selector(handleSingleTapGes))
        contentScrollView.addGestureRecognizer(singleTapGesture)
        
        doubleTapGesture.addTarget(self, action: #selector(handleDoubleTapGes(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        contentScrollView.addGestureRecognizer(doubleTapGesture)
        
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePanGes(_:)))
        contentScrollView.addGestureRecognizer(panGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    func cellDidScroll() {
        
    }
    
    // MARK: Request
    func setAsset(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        cancelRequest()
        setProgress(1)
        
        contentScrollView.setZoomScale(1, animated: false)
        assetImageView.frame = AssetSizeHelper.imageViewRectFrom(imageSize: model.asset.pixelSize, mediaType: model.mediaType)
        contentScrollView.contentSize = assetImageView.frame.size
        contentScrollView.maximumZoomScale = AssetSizeHelper.imageViewMaxZoomScaleFrom(imageSize: model.asset.pixelSize)
        requestImage(model, thumbnail: thumbnail, pickerConfig: pickerConfig)
    }
    
    func requestImage(_ model: AssetModel, thumbnail: UIImage?, pickerConfig: PickerConfig) {
        if let image = model.displayingImage {
            assetImageView.image = image
            requestOtherAssetData(model)
            return
        }
        assetImageView.image = thumbnail
        
        let options = AssetFetchOptions()
        options.sizeOption = .specify(pickerConfig.maximumPreviewSize)
        options.progressHandler = defaultProgressHandle
        
        assetRequest = AssetFetchTool.requestImage(for: model.asset, options: options) { [weak self] result, requestId in
            self?.setProgress(1)
            switch result {
            case .success(let response):
                if !response.isDegraded {
                    self?.assetImageView.image = response.image
                    self?.requestOtherAssetData(model)
                }
            case .failure: break
            }
        }
    }
    
    func requestOtherAssetData(_ model: AssetModel) {
        
    }
    
    func cancelRequest() {
        assetRequest?.cancel()
        assetRequest = nil
        assetImageView.image = nil
    }
    
    func defaultProgressHandle(progress: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.setProgress(progress)
        }
    }
    
    func setProgress(_ progress: Double) {
        iCloudView.isHidden = progress == 1
        iCloudView.progress = progress
    }
    
    // MARK: GestureRecognizer
    @objc func handleSingleTapGes() {
        delegate?.previewCellSingleTap(self)
    }
    
    @objc func handleDoubleTapGes(_ gesture: UITapGestureRecognizer) {
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
    
    @objc func handlePanGes(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginPanGes()
        case .changed:
            let translation = gesture.translation(in: self)
            changedPanGes(translation: translation)
        default:
            if contentView.frame.origin.y > 80 || gesture.velocity(in: self).y > 500 {
                finishPanGes(dismiss: true)
            } else {
                finishPanGes(dismiss: false)
            }
        }
    }
    
    func beginPanGes() {
        delegate?.previewCellSingleTapDidBeginPan(self)
    }
    
    func changedPanGes(translation: CGPoint) {
        let transForm = min(1 - translation.y / UIScreen.height, 1)
        contentScrollView.transform = CGAffineTransform(scaleX: transForm, y: transForm)
        contentView.x = translation.x
        contentView.y = translation.y
        let scale = min(1 - translation.y / UIScreen.height * 2, 1)
        delegate?.previewCellSingleTap(self, didPanScale: scale)
    }
    
    func finishPanGes(dismiss: Bool) {
        if dismiss {
            delegate?.previewCellSingleTap(self, didFinishPanDismiss: true)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, animations: {
                self.contentView.frame.origin = .zero
                self.contentScrollView.transform = .identity
                self.delegate?.previewCellSingleTap(self, didFinishPanDismiss: false)
            })
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        cancelRequest()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentScrollView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AssetPreviewCell: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return assetImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        assetImageView.center = AssetSizeHelper.imageViewCenterWhenZoom(scrollView)
    }
    
}

extension AssetPreviewCell: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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

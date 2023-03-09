//
//  AssetPreviewAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

extension AssetPreviewViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator.init(duration: 0.45 , timingParameters: parameters)
        return AssetPreviewShowTransitioning(animator: animator)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator.init(duration: 0.4 , timingParameters: parameters)
        return AssetPreviewDismissTransitioning(animator: animator)
    }
    
}

private class AssetPreviewShowTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animator: UIViewPropertyAnimator
    
    init(animator: UIViewPropertyAnimator) {
        self.animator = animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? AssetPreviewViewController else {
            transitionContext.completeTransition(false)
            return
        }
        transitionContext.containerView.addSubview(toVC.view)
        toVC.showAnimation(animator: animator) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
    
}

private class AssetPreviewDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animator: UIViewPropertyAnimator
    
    init(animator: UIViewPropertyAnimator) {
        self.animator = animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .from) as? AssetPreviewViewController else {
            transitionContext.completeTransition(false)
            return
        }
        toVC.dismissAnimation(animator: animator) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
    
}

extension AssetPreviewViewController {
    
    fileprivate func showAnimation(animator: UIViewPropertyAnimator, completion: @escaping (Bool) -> ()) {
        if let currentIndex = self.currentIndex,
           let currentAsset = assetFetchTool.albumModel?.assets[currentIndex],
           let sourceImageView = animateDataSource?.imageBrowser(self, sourceViewFor: currentIndex),
           let image = currentAsset.displayingPhoto ?? sourceImageView.image,
           let imageOrginFrame = sourceImageView.superview?.convert(sourceImageView.frame, to: view.window) {
            
            sourceImageView.isHidden = true
            collectionView.isHidden = true
            
            let animateImageView = UIImageView()
            animateImageView.contentMode = .scaleAspectFill
            animateImageView.clipsToBounds = true
            animateImageView.isHidden = false
            animateImageView.image = image
            animateImageView.frame = imageOrginFrame
            animateImageView.layer.cornerRadius = sourceImageView.layer.cornerRadius
            view.addSubview(animateImageView)
            
            let mediaType = currentAsset.mediaType
            let animateImageViewToFrame = AssetDisplayHelper.imageViewRectFrom(imageSize: image.size, mediaType: mediaType)
            
            animator.addAnimations {
                animateImageView.layer.cornerRadius = 0
                animateImageView.frame = animateImageViewToFrame
            }
            
            var assetRequest: AssetFetchRequest?
            if currentAsset.displayingPhoto == nil {
                let options = AssetFetchOptions()
                options.sizeOption = .specify(config.pickerConfig.maximumPreviewSize)
                options.imageDeliveryMode = .highQualityFormat
                assetRequest = AssetFetchTool.requestPhoto(for: currentAsset.asset, options: options) { result, _ in
                    if case let .success(response) = result {
                        animateImageView.image = response.photo
                    }
                }
            }
            
            animator.addCompletion { [unowned self] _ in
                animateImageView.removeFromSuperview()
                sourceImageView.isHidden = false
                self.collectionView.isHidden = false
                assetRequest?.cancel()
            }
            
            toolbars.forEach {
                view.bringSubviewToFront($0)
            }
            
        } else {
            collectionView.alpha = 0
            animator.addAnimations { [unowned self] in
                self.collectionView.alpha = 1
            }
        }
        
        view.backgroundColor = .clear
        toolbars.forEach { $0.alpha = 0 }
        
        animator.addAnimations { [unowned self] in
            self.view.backgroundColor = WLPhotoUIConfig.default.color.previewBackground
            self.toolbars.forEach { $0.alpha = 1 }
        }
        
        animator.addCompletion { position in
            completion(position == .end)
        }
        
        animator.startAnimation()
    }
    
    fileprivate func dismissAnimation(animator: UIViewPropertyAnimator, completion: @escaping (Bool) -> ()) {
        if let currentIndex = collectionView.indexPathsForVisibleItems.first?.item,
           let cellImageView = (collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? AssetPreviewCell)?.assetImageView,
           let image = cellImageView.image,
           let sourceImageView = animateDataSource?.imageBrowser(self, sourceViewFor: currentIndex),
           let imageFromFrame = cellImageView.superview?.convert(cellImageView.frame, to: view.window),
           let imageToFrame = sourceImageView.superview?.convert(sourceImageView.frame, to: view.window) {
            
            let animateImageView = UIImageView()
            animateImageView.contentMode = .scaleAspectFill
            animateImageView.clipsToBounds = true
            animateImageView.isHidden = false
            animateImageView.image = image
            animateImageView.frame = imageFromFrame
            view.addSubview(animateImageView)
            
            animator.addAnimations {
                animateImageView.layer.cornerRadius = sourceImageView.layer.cornerRadius
                animateImageView.frame = imageToFrame
            }
            
            sourceImageView.isHidden = true
            animator.addCompletion { _ in
                sourceImageView.isHidden = false
            }
            
            collectionView.isHidden = true
            toolbars.forEach {
                $0.superview?.bringSubviewToFront($0)
            }
            
        } else {
            animator.addAnimations { [unowned self] in
                self.collectionView.alpha = 0
            }
        }
        animator.addAnimations { [unowned self] in
            self.view.backgroundColor = .clear
        }
        
        animator.addCompletion { position in
            completion(position == .end)
        }
        
        animator.startAnimation()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.toolbars.forEach { $0.alpha = 0 }
        })
    }
    
}

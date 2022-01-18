//
//  AssetPreviewAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/14.
//

import UIKit

class AssetPreviewShowTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? AssetPreviewViewController else {
            transitionContext.completeTransition(false)
            return
        }
        transitionContext.containerView.addSubview(toVC.view)
        let duration = transitionDuration(using: transitionContext)
        toVC.showAnimation(duration: duration) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
}

class AssetPreviewDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .from) as? AssetPreviewViewController else {
            transitionContext.completeTransition(false)
            return
        }
        let duration = transitionDuration(using: transitionContext)
        toVC.dismissAnimation(duration: duration) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
}

extension AssetPreviewViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AssetPreviewShowTransitioning()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AssetPreviewDismissTransitioning()
    }
    
}

extension AssetPreviewViewController {
    
    fileprivate func showAnimation(duration: Double, completion: @escaping (Bool) -> ()) {
        var animations: () -> () = {}
        
        if let currentIndex = self.currentIndex,
           let imageView = animateDataSource?.imageBrowser(self, sourceViewFor: currentIndex),
           let image = imageView.image,
           let imageOrginFrame = imageView.superview?.convert(imageView.frame, to: view.window),
           let assetSize = animateDataSource?.imageBrowser(self, assetSizeFor: currentIndex) {
            animateImageView.isHidden = false
            collectionView.isHidden = true
            animateImageView.image = image
            animateImageView.frame = imageOrginFrame
            animateImageView.layer.cornerRadius = imageView.layer.cornerRadius
            let mediaType = assetFetchTool.albumModel?.assets[currentIndex].mediaType ?? .photo
            animations = {
                self.animateImageView.frame = AssetSizeHelper.imageViewRectFrom(imageSize: assetSize, mediaType: mediaType)
            }
        } else {
            animateImageView.isHidden = true
            collectionView.isHidden = false
            collectionView.alpha = 0
            animations = {
                self.collectionView.alpha = 1
            }
        }
        
        toolbars.forEach {
            $0.alpha = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = .white
            animations()
            self.toolbars.forEach {
                $0.alpha = 1
            }
        }) { (completed) in
            self.animateImageView.isHidden = true
            self.collectionView.isHidden = false
            completion(completed)
        }
    }
    
    fileprivate func dismissAnimation(duration: Double, completion: @escaping (Bool) -> ()) {
        var animations: () -> () = { }
        
        if let currentIndex = collectionView.indexPathsForVisibleItems.first?.item,
           let cellImageView = (collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? AssetPreviewCell)?.assetImageView,
           let image = cellImageView.image,
           let sourceImageView = animateDataSource?.imageBrowser(self, sourceViewFor: currentIndex),
           let imageFromFrame = cellImageView.superview?.convert(cellImageView.frame, to: view.window),
           let imageToFrame = sourceImageView.superview?.convert(sourceImageView.frame, to: view.window) {
            collectionView.isHidden = true
            animateImageView.isHidden = false
            animateImageView.image = image
            animateImageView.frame = imageFromFrame
            animations = {
                self.animateImageView.frame = imageToFrame
            }
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            animations()
            self.view.backgroundColor = .clear
        }) { (completed) in
            completion(completed)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.toolbars.forEach {
                $0.alpha = 0
            }
        }, completion: nil)
    }
    
}

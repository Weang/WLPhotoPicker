//
//  PhotoEditCropAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

extension PhotoEditCropViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoEditCropShowTransitioning()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoEditCropDismissTransitioning()
    }
    
}

private class PhotoEditCropShowTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? PhotoEditCropViewController,
              let fromVC = transitionContext.viewController(forKey: .from) as? PhotoEditViewController else {
                  transitionContext.completeTransition(false)
                  return
              }
        
        transitionContext.containerView.addSubview(toVC.view)
        let duration = transitionDuration(using: transitionContext)
        toVC.showAnimation(duration: duration, from: fromVC) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
}

private class PhotoEditCropDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PhotoEditCropViewController,
              let toVC = transitionContext.viewController(forKey: .to) as? PhotoEditViewController else {
                  transitionContext.completeTransition(false)
                  return
              }
        let duration = transitionDuration(using: transitionContext)
        fromVC.dismissAnimation(duration: duration, to: toVC) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
}

extension PhotoEditCropViewController {
    
    fileprivate func showAnimation(duration: Double, from editViewController: PhotoEditViewController, completion: @escaping (Bool) -> ()) {
        let photo = self.photo.rotate(orientation: cropRotation).cropToRect(cropRect)
        
        let animateImageView = UIImageView()
        animateImageView.image = photo
        animateImageView.frame = editViewController.contentScrollView.convert(editViewController.imageContainerView.frame,
                                                                              to: editViewController.view)
        editViewController.view.addSubview(animateImageView)
        
        editViewController.contentImageView.isHidden = true
        editViewController.maskLayerContentView.isHidden = true
        editViewController.view.bringSubviewToFront(editViewController.topToolBar)
        editViewController.view.bringSubviewToFront(editViewController.bottomToolBar)
        view.alpha = 0
        
        let animateToFrame: CGRect
        if cropRect == .identity && cropRotation == .up  {
            animateToFrame = contentScrollView.convert(contentImageView.frame, to: view)
        } else {
            animateToFrame = adjustDisplayRect(photo.size)
        }
        
        UIView.animate(withDuration: duration - 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            animateImageView.frame = animateToFrame
            editViewController.topToolBar.alpha = 0
            editViewController.bottomToolBar.alpha = 0
        })
        
        UIView.animate(withDuration: 0.2, delay: duration - 0.2, animations: {
            self.view.alpha = 1
        }) { (completed) in
            animateImageView.removeFromSuperview()
            editViewController.contentImageView.isHidden = false
            editViewController.maskLayerContentView.isHidden = false
            editViewController.topToolBar.alpha = 1
            editViewController.bottomToolBar.alpha = 1
            completion(completed)
        }
    }
    
    fileprivate func dismissAnimation(duration: Double, to editViewController: PhotoEditViewController, completion: @escaping (Bool) -> ()) {
        let image = cropedImage ?? photo
        let fromRect = adjustDisplayRect(image.size)
        
        let animateImageView = UIImageView()
        animateImageView.image = image
        animateImageView.frame = fromRect
        editViewController.view.addSubview(animateImageView)
        
        editViewController.view.bringSubviewToFront(editViewController.topToolBar)
        editViewController.view.bringSubviewToFront(editViewController.bottomToolBar)
        editViewController.maskLayerContentView.isHidden = true
        editViewController.contentImageView.isHidden = true
        editViewController.topToolBar.alpha = 0
        editViewController.bottomToolBar.alpha = 0
        
        UIView.animate(withDuration: 0.05, delay: 0, animations: {
            self.view.alpha = 0
        })
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            animateImageView.frame = editViewController.contentScrollView.convert(editViewController.imageContainerView.frame,
                                                                                  to: editViewController.view)
            editViewController.topToolBar.alpha = 1
            editViewController.bottomToolBar.alpha = 1
        }) { (completed) in
            animateImageView.removeFromSuperview()
            editViewController.maskLayerContentView.isHidden = false
            editViewController.contentImageView.isHidden = false
            completion(completed)
        }
    }
    
}

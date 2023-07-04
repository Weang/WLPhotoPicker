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
              let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        transitionContext.containerView.addSubview(toVC.view)
        let duration = transitionDuration(using: transitionContext)
        if let editViewController = fromVC as? PhotoEditViewController {
            toVC.showAnimation(duration: duration, from: editViewController) { completion in
                transitionContext.completeTransition(completion)
            }
        } else {
            toVC.showAnimation(duration: duration, from: fromVC) { completion in
                transitionContext.completeTransition(completion)
            }
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 10
    }
    
}

private class PhotoEditCropDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PhotoEditCropViewController,
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        let duration = transitionDuration(using: transitionContext)
        if let editViewController = toVC as? PhotoEditViewController {
            fromVC.dismissAnimation(duration: duration, to: editViewController) { completion in
                transitionContext.completeTransition(completion)
            }
        } else {
            fromVC.dismissAnimation(duration: duration, to: toVC) { completion in
                transitionContext.completeTransition(completion)
            }
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
}

// 从编辑页面跳转裁剪页面动画
extension PhotoEditCropViewController {
    
    fileprivate func showAnimation(duration: Double, from editViewController: PhotoEditViewController, completion: @escaping (Bool) -> ()) {
        let photo = self.photo.rotate(orientation: cropOrientation).cropToRect(cropRect)
        
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
        if cropRect == .identity && cropOrientation == .up  {
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

// 指定animationSourceImageView之后从其他页面跳转动画
extension PhotoEditCropViewController {
    
    fileprivate func showAnimation(duration: Double, from viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        guard let animationSourceImageView = animationSourceImageView else {
            completion(false)
            return
        }
        
        let photo = photo.rotate(orientation: cropOrientation).cropToRect(cropRect)
        
        let animateImageView = UIImageView()
        animateImageView.image = photo
        animateImageView.frame = animationSourceImageView.superview?.convert(animationSourceImageView.frame, to: viewController.view) ?? .zero
        viewController.view.addSubview(animateImageView)
        
        let animateToFrame: CGRect
        if cropRect == .identity && cropOrientation == .up  {
            animateToFrame = contentScrollView.convert(contentImageView.frame, to: view)
        } else {
            animateToFrame = adjustDisplayRect(photo.size)
        }
        
        view.backgroundColor = .clear
        
        UIView.animate(withDuration: duration * 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: { [unowned self] in
            animateImageView.frame = animateToFrame
            view.backgroundColor = .black
        })
        
        UIView.animate(withDuration: duration * 0.4, delay: duration * 0.6, animations: {
            self.view.alpha = 1
        }) { (completed) in
            animateImageView.removeFromSuperview()
            completion(completed)
        }
    }
    
    fileprivate func dismissAnimation(duration: Double, to viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        guard let animationSourceImageView = animationSourceImageView else {
            completion(false)
            return
        }
        
        let image = cropedImage ?? photo
        let fromRect = adjustDisplayRect(image.size)
        
        let animateImageView = UIImageView()
        animateImageView.image = image
        animateImageView.frame = fromRect
        viewController.view.addSubview(animateImageView)
        
        UIView.animate(withDuration: 0.05, delay: 0, animations: {
            self.view.alpha = 0
        })
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            animateImageView.frame = animationSourceImageView.superview?.convert(animationSourceImageView.frame, to: viewController.view) ?? .zero
        }) { (completed) in
            animateImageView.removeFromSuperview()
            completion(completed)
        }
    }
    
}

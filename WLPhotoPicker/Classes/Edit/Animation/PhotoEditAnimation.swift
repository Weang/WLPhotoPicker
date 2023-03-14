//
//  PhotoEditAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2023/3/13.
//

import UIKit

extension PhotoEditViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator.init(duration: 0.5 , timingParameters: parameters)
        return PhotoEditShowTransitioning(animator: animator)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator.init(duration: 0.5 , timingParameters: parameters)
        return PhotoEditDismissTransitioning(animator: animator)
    }
    
}

private class PhotoEditShowTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animator: UIViewPropertyAnimator
    
    init(animator: UIViewPropertyAnimator) {
        self.animator = animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? PhotoEditViewController else {
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

private class PhotoEditDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animator: UIViewPropertyAnimator
    
    init(animator: UIViewPropertyAnimator) {
        self.animator = animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PhotoEditViewController else {
            transitionContext.completeTransition(false)
            return
        }
        fromVC.dismissAnimation(animator: animator) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
    
}

extension PhotoEditViewController {
    
    fileprivate func showAnimation(animator: UIViewPropertyAnimator, completion: @escaping (Bool) -> ()) {
        if let sourceImageView = animationSourceImageView,
           let imageOrginFrame = sourceImageView.superview?.convert(sourceImageView.frame, to: view.window) {
            
            let animateImageView = UIImageView()
            animateImageView.contentMode = .scaleAspectFill
            animateImageView.clipsToBounds = true
            animateImageView.isHidden = false
            animateImageView.image = photo
            animateImageView.frame = imageOrginFrame
            animateImageView.layer.cornerRadius = sourceImageView.layer.cornerRadius
            view.addSubview(animateImageView)
            
            editContentView.backgroundColor = .clear
            topToolBar.alpha = 0
            topToolBar.superview?.bringSubviewToFront(topToolBar)
            bottomToolBar.alpha = 0
            bottomToolBar.superview?.bringSubviewToFront(bottomToolBar)
            contentImageView.isHidden = true
            sourceImageView.isHidden = true
            
            animator.addAnimations { [unowned self] in
                animateImageView.layer.cornerRadius = 0
                animateImageView.frame = AssetDisplayHelper.imageViewRectFrom(imageSize: self.photo.size, mediaType: .photo)
                self.editContentView.backgroundColor = .black
                self.topToolBar.alpha = 1
                self.bottomToolBar.alpha = 1
            }
            
            animator.addCompletion { [unowned self] _ in
                animateImageView.removeFromSuperview()
                sourceImageView.isHidden = false
                self.contentImageView.isHidden = false
            }
            
        } else {
            view.alpha = 0
            animator.addAnimations { [unowned self] in
                self.view.alpha = 1
            }
        }
        
        animator.addCompletion { position in
            completion(position == .end)
        }
        
        animator.startAnimation()
    }
    
    fileprivate func dismissAnimation(animator: UIViewPropertyAnimator, completion: @escaping (Bool) -> ()) {
        animator.addAnimations { [unowned self] in
            self.view.alpha = 0
        }
        animator.addCompletion { position in
            completion(position == .end)
        }
        animator.startAnimation()
    }
    
}

//
//  AlbumListAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import UIKit

class AlbumListAnimation: NSObject {
    
    fileprivate var isPresenting = false
    
    let topMargin: CGFloat = 88
    
}

extension AlbumListAnimation: UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toVC = transitionContext.viewController(forKey: isPresenting ? .to : .from) as? AlbumListViewController else {
            transitionContext.completeTransition(false)
            return
        }
        container.addGestureRecognizer(toVC.dismissTapGesture)
        container.addSubview(toVC.view)
        toVC.view.frame = CGRect(x: 0,
                                 y: topMargin,
                                 width: UIScreen.width,
                                 height: UIScreen.height - topMargin)
        let duration = transitionDuration(using: transitionContext)
        if isPresenting {
            toVC.showAnimation(duration: duration) { complete in
                transitionContext.completeTransition(complete)
            }
        } else {
            toVC.dismissAnimation(duration: duration) { complete in
                transitionContext.completeTransition(complete)
            }
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresenting {
            return 0.4
        } else {
            return 0.3
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
}

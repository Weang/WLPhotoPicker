//
//  PhotoEditPasterAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

extension PhotoEditPasterViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoEditPasterShowTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoEditPasterDismissTransitioning()
    }
    
}

private class PhotoEditPasterShowTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? PhotoEditPasterViewController else {
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

private class PhotoEditPasterDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .from) as? PhotoEditPasterViewController else {
            transitionContext.completeTransition(false)
            return
        }
        let duration = transitionDuration(using: transitionContext)
        toVC.dismissAnimation(duration: duration) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
}

extension PhotoEditPasterViewController {
    
    fileprivate func showAnimation(duration: Double, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.backgroundView.snp.updateConstraints { make in
                make.bottom.equalTo(0)
            }
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
            self.view.layoutIfNeeded()
        }) { (completed) in
            completion(completed)
        }
    }
    
    fileprivate func dismissAnimation(duration: Double, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = .clear
            self.backgroundView.snp.updateConstraints { make in
                make.bottom.equalTo(self.backgroundViewHeight)
            }
            self.view.layoutIfNeeded()
        }) { (completed) in
            completion(completed)
        }
    }
    
}

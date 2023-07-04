//
//  AlbumListAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import UIKit

extension AlbumListViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator.init(duration: 0.5 , timingParameters: parameters)
        return AlbumListShowTransitioning(animator: animator)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator.init(duration: 0.3 , timingParameters: parameters)
        return AlbumListDismissTransitioning(animator: animator)
    }
    
}

private class AlbumListShowTransitioning: NSObject,  UIViewControllerAnimatedTransitioning {
    
    let animator: UIViewPropertyAnimator
    
    init(animator: UIViewPropertyAnimator) {
        self.animator = animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? AlbumListViewController else {
            transitionContext.completeTransition(false)
            return
        }
        let fromVC = transitionContext.viewController(forKey: .from) as? UINavigationController
        let topMargin = UIApplication.shared.statusBarFrame.height + (fromVC?.navigationBar.bounds.size.height ?? 0)
        toVC.view.frame = CGRect(x: 0, y: topMargin, width: UIScreen.width, height: UIScreen.height - topMargin)
        let container = transitionContext.containerView
        container.addGestureRecognizer(toVC.dismissTapGesture)
        container.addSubview(toVC.view)
        
        toVC.showAnimation(animator: animator) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
}

private class AlbumListDismissTransitioning: NSObject,  UIViewControllerAnimatedTransitioning {
    
    let animator: UIViewPropertyAnimator
    
    init(animator: UIViewPropertyAnimator) {
        self.animator = animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .from) as? AlbumListViewController else {
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

extension AlbumListViewController {
    
    fileprivate func showAnimation(animator: UIViewPropertyAnimator, completion: @escaping (Bool) -> ()) {
        animator.addAnimations {
            self.tableViewContentView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(self.tableView.snp.height)
            }
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
            self.view.layoutIfNeeded()
        }
        animator.addCompletion { position in
            completion(position == .end)
        }
        
        animator.startAnimation()
    }
    
    fileprivate func dismissAnimation(animator: UIViewPropertyAnimator, completion: @escaping (Bool) -> ()) {
        animator.addAnimations {
            self.tableViewContentView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(0)
            }
            self.view.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }
        animator.addCompletion { position in
            completion(position == .end)
        }
        
        animator.startAnimation()
    }
    
}

//
//  AlbumListAnimation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import UIKit

extension AlbumListViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlbumListShowTransitioning()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlbumListDismissTransitioning()
    }
    
}

private class AlbumListShowTransitioning: NSObject,  UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? AlbumListViewController else {
            transitionContext.completeTransition(false)
            return
        }
        let topMargin = keyWindowSafeAreaInsets.top + 44
        toVC.view.frame = CGRect(x: 0, y: topMargin, width: UIScreen.width, height: UIScreen.height - topMargin)
        let container = transitionContext.containerView
        container.addGestureRecognizer(toVC.dismissTapGesture)
        container.addSubview(toVC.view)
        
        let duration = transitionDuration(using: transitionContext)
        toVC.showAnimation(duration: duration) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
}

private class AlbumListDismissTransitioning: NSObject,  UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .from) as? AlbumListViewController else {
            transitionContext.completeTransition(false)
            return
        }
        let duration = transitionDuration(using: transitionContext)
        toVC.dismissAnimation(duration: duration) { completion in
            transitionContext.completeTransition(completion)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}

extension AlbumListViewController {
    
    fileprivate func showAnimation(duration: Double, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.tableViewContentView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(self.tableView.snp.height)
            }
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
            self.view.layoutIfNeeded()
        }) { (completed) in
            completion(completed)
        }
    }
    
    fileprivate func dismissAnimation(duration: Double, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.tableViewContentView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(0)
            }
            self.view.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }) { (completed) in
            completion(completed)
        }
    }
    
}

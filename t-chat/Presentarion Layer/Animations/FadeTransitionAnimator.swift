//
//  FadeTransitionAnimator.swift
//  t-chat
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

final class FadeTransitionAnimator: NSObject {
    private let animationDuration: Double
    private let type: AnimationType
    
    init(animationDuration: Double, type: AnimationType) {
        self.animationDuration = animationDuration
        self.type = type
    }
}

extension FadeTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: animationDuration) ?? 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        toVC.view.alpha = 0.0
        
        transitionContext.containerView.addSubview(fromVC.view)
        transitionContext.containerView.addSubview(toVC.view)

        UIView.animate(withDuration: animationDuration, animations: {
            toVC.view.alpha = 1.0
        }, completion: { _ in
            fromVC.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

enum AnimationType {
    case present, dismiss
}

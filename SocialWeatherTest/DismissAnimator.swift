//
//  DismissAnimator.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 04-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Safely get the view controllers and a container view
        guard
            let from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let to = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let container = transitionContext.containerView()
            else {
                return
            }
        
        // Insert the to view into the container view
        container.insertSubview(to.view, belowSubview: from.view)
        
        // Actually animate the views
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            var geo = from.view.center;
            geo.y += UIScreen.mainScreen().bounds.size.height
            from.view.center = geo
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
}
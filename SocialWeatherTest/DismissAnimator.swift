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
        
        // Hide the from view as we're going to use snapshots for better performance
        from.view.hidden = true
        
        // Make and insert the snapshot we were just talking about
        let snapshot = from.view.snapshotViewAfterScreenUpdates(false)
        container.insertSubview(snapshot, aboveSubview: to.view)
        
        // Actually animate the views
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            var geo = snapshot.center;
            geo.y += UIScreen.mainScreen().bounds.size.height
            snapshot.center = geo
        }, completion: { _ in
            from.view.hidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
}
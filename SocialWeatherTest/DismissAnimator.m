//
//  DismissAnimator.m
//  SocialWeatherTest
//
//  Created by R. de Vries on 02-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

#import "DismissAnimator.h"

@implementation DismissAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *from = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    [container insertSubview: to.view belowSubview: from.view];
    
    from.view.hidden = YES;
    
    UIView *snapshot = [from.view snapshotViewAfterScreenUpdates: NO];
    [container insertSubview: snapshot aboveSubview: to.view];
    
    [UIView animateWithDuration: [self transitionDuration: transitionContext] animations: ^{
        CGPoint geo = snapshot.center;
        geo.y += [UIScreen mainScreen].bounds.size.height;
        [snapshot setCenter: geo];
    } completion: ^(BOOL _){
        from.view.hidden = NO;
        
        [snapshot removeFromSuperview];
        [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
    }];
}

@end
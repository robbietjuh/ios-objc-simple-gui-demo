//
//  IntroViewController.m
//  SocialWeatherTest
//
//  Created by R. de Vries on 02-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

#import "IntroViewController.h"
#import "PhotoViewController.h"
#import "Interactor.h"
#import "DismissAnimator.h"

@interface IntroViewController ()

@property (nonatomic) Interactor *interactor;

@end

@implementation IntroViewController

#pragma mark - View setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up a new instance of the Interactor
    self.interactor = [[Interactor alloc] init];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString: @"TransitionToPhotoViewController"]) {
        // This is a transition to the PhotoViewController view, so we'll have to inject
        // ourselves as the transitioning delegate and the interactor as a shared interactor.
        // The key "TransitionToPhotoViewController" is set in the Storyboard.
        PhotoViewController *controller = (PhotoViewController *)segue.destinationViewController;
        
        controller.transitioningDelegate = self;
        controller.interactor = self.interactor;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissAnimator alloc] init];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactor.hasStarted ? self.interactor : nil;
}

@end

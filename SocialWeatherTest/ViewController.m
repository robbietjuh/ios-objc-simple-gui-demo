//
//  ViewController.m
//  SocialWeatherTest
//
//  Created by R. de Vries on 01-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *blurContainer;
@property (weak, nonatomic) IBOutlet UIView *userDetailView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
}

- (void)setupScrollView {
    CGSize baseFrame = self.view.frame.size;
    CGSize detailFrame = self.userDetailView.frame.size;
    
    [self.scrollView setContentSize: CGSizeMake(baseFrame.width, baseFrame.height * 2 - detailFrame.height)];
    [self.scrollView setPagingEnabled: YES];
    [self.scrollView setDelegate: self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = [scrollView contentOffset];
    
    // Update alpha of the blurry layer
    float alpha = MIN(offset.y / 100.0, 1.0);
    [self.blurContainer setAlpha: alpha];
}

@end

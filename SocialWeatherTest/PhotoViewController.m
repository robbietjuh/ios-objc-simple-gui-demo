//
//  PhotoViewController
//  SocialWeatherTest
//
//  Created by R. de Vries on 01-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *blurContainer;
@property (weak, nonatomic) IBOutlet UIView *userDetailView;

@end

@implementation PhotoViewController

#pragma mark - View setup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
}

- (void)setupScrollView {
    CGSize baseFrame = self.view.frame.size;
    CGSize detailFrame = self.userDetailView.frame.size;
    
    [self.scrollView setContentSize: CGSizeMake(baseFrame.width, baseFrame.height * 2 - detailFrame.height)];
    [self.scrollView setTag: 1337];
    [self.scrollView setPagingEnabled: YES];
    [self.scrollView setDelegate: self];
    
    [self.scrollView.panGestureRecognizer addTarget: self action: @selector(handleGesture:)];
}

#pragma mark - Scroll view handlers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Check for the scrollview tag. We don't want to apply blur updates when the user scrolls
    // the tableview that is actually inside the scrollview.
    if(scrollView.tag != 1337)
        return;
    
    CGPoint offset = [scrollView contentOffset];
    
    // Update alpha of the blurry layer
    float alpha = MIN(offset.y / 100.0, 1.0);
    [self.blurContainer setAlpha: alpha];
}

- (void)handleGesture:(UIPanGestureRecognizer *)sender {
    CGFloat percentThreshold = 0.3;
    
    // Require the scrollview to be at its top
    if(sender.view != self.scrollView || self.scrollView.contentOffset.y > 0) {
        return;
    }
    
    // Calculate the percentage of screen real estate the user has 'pulled'
    CGPoint position = [sender translationInView: self.view];
    CGFloat movementOnAxis = position.y / self.view.bounds.size.height;
    CGFloat positiveMovementOnAxis = MAX(movementOnAxis, 0.0);
    CGFloat movementPercentage = MIN(positiveMovementOnAxis, 1.0);
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.interactor.hasStarted = YES;
            [self dismissViewControllerAnimated: YES completion: nil];
            break;
            
        case UIGestureRecognizerStateChanged:
            self.interactor.shouldFinish = movementPercentage > percentThreshold;
            [self.interactor updateInteractiveTransition: movementPercentage];
            break;
            
        case UIGestureRecognizerStateCancelled:
            self.interactor.hasStarted = NO;
            [self.interactor cancelInteractiveTransition];
            break;
            
        case UIGestureRecognizerStateEnded:
            self.interactor.hasStarted = NO;
            if(self.interactor.shouldFinish)
                [self.interactor finishInteractiveTransition];
            else
                [self.interactor cancelInteractiveTransition];
            break;
            
        default:
            break;
    }
}

#pragma mark - Table view content handlers

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Render 20 cells
    return section == 0 ? 20 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if(indexPath.row == 0) {
        // The very first cell should be one that allows the user to comment on the photo
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"createCommentCell"];
        
        // Add our avatar to the left
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame: CGRectMake(20, 10, 25, 25)];
        avatarImageView.backgroundColor = [UIColor clearColor];
        avatarImageView.image = [UIImage imageNamed: @"round-profile.png"];
        [cell addSubview: avatarImageView];
        
        // Now create a textfield with a opaque placeholder text and add it to the right
        UIColor *placeholderColor = [UIColor colorWithRed: 255 green: 255 blue: 255 alpha: 0.5];
        UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(60, 0, self.view.frame.size.width - 90, cell.frame.size.height)];
        textField.textColor = [UIColor whiteColor];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Tap here to comment..."
                                                                          attributes: @{ NSForegroundColorAttributeName: placeholderColor }];
        [cell addSubview: textField];
    }
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"commentCell"];
        
        // Add 'their' avatar to the left
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame: CGRectMake(20, 10, 25, 25)];
        avatarImageView.backgroundColor = [UIColor clearColor];
        avatarImageView.image = [UIImage imageNamed: @"avatar-phil-schiller.png"];
        [cell addSubview: avatarImageView];
        
        // Set up some kind of a comment
        cell.textLabel.text = @"I like your photos, Phil!";
        cell.indentationWidth = 40;
        cell.indentationLevel = 1;
        cell.detailTextLabel.text = @"3h";
        cell.detailTextLabel.textColor = [UIColor colorWithRed: 255 green: 255 blue: 255 alpha: 0.5];
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end

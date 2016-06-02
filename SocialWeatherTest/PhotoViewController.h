//
//  PhotoViewController
//  SocialWeatherTest
//
//  Created by R. de Vries on 01-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interactor.h"

@interface PhotoViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Interactor *interactor;

@end


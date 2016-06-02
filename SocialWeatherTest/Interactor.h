//
//  Interactor.h
//  SocialWeatherTest
//
//  Created by R. de Vries on 02-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Interactor : UIPercentDrivenInteractiveTransition

@property (nonatomic) bool hasStarted;
@property (nonatomic) bool shouldFinish;

@end

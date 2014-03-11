//
//  AppDelegate.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ADWindow;
@class PartnersAlertWindow;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ADWindow *adWindow;

@property (strong, nonatomic) PartnersAlertWindow *alertViewCache;
@end

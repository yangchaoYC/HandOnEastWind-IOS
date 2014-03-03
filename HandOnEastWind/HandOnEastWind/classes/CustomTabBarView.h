//
//  CustomTabBarView.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-23.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomTabBarViewSelectedDelegate;

@interface CustomTabBarView : UIView
@property(nonatomic,assign)id<CustomTabBarViewSelectedDelegate> selectedDelegate;

@end

@protocol CustomTabBarViewSelectedDelegate <NSObject>

- (void)selectedTabBarAtIndex:(NSInteger)index_;

@end

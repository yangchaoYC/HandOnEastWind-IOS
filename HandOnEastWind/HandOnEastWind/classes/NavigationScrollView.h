//
//  NavigationScrollView.h
//  Test2
//
//  Created by jijeMac2 on 14-2-27.
//  Copyright (c) 2014年 jijesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NavigationScrollViewSlectedDelegate;

@interface NavigationScrollView : UIScrollView

@property(assign,nonatomic)id<NavigationScrollViewSlectedDelegate> selectedDelegate;

- (void)initNavigations:(NSArray *)navigations_;
- (void)selectNavigationAtIndex:(int)index_;
- (void)updateAttentionViewFrame:(CGFloat)contentOffsetX_;

@end
@protocol NavigationScrollViewSlectedDelegate

- (void)selectedNavigationItemAtIndex:(int)index_;

@end
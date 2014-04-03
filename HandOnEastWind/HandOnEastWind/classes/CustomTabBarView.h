//
//  CustomTabBarView.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-23.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBarView : UIView
@property(nonatomic,assign)int currentSelectedIndex;
@property(nonatomic,copy)void(^selectdCallBackBlock)(int selectedIndex);
@end
//
//  CustomTabBarView.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-23.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "CustomTabBarView.h"

@implementation CustomTabBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(IBAction)btnClick:(id)sender
{
    [self.selectedDelegate selectedTabBarAtIndex:[sender tag]];
}

@end

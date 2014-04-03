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

- (void)awakeFromNib
{
    self.currentSelectedIndex = 0;
    for (UIImageView *item in [self subviews]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTap:)];
        [item addGestureRecognizer:tap];
        
        if (item.tag == self.currentSelectedIndex) {
            [item setHighlighted:YES];
        }
    }
}

-(void)itemTap:(UITapGestureRecognizer *)ges
{
    if (self.currentSelectedIndex != ges.view.tag) {
        self.selectdCallBackBlock(ges.view.tag);
    }
}

@end

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)itemTap:(UITapGestureRecognizer *)ges
{
    if (self.currentSelectedIndex != ges.view.tag) {
        
        for (UIImageView *item in [self subviews]) {
            if (item.tag == self.currentSelectedIndex) {
                [item setHighlighted:NO];
            }
            if (item.tag == ges.view.tag) {
                [item setHighlighted:YES];
            }
        }
        
        [self.selectedDelegate selectedTabBarAtIndex:[ges.view tag]];
        
        self.currentSelectedIndex = ges.view.tag;
    }
}

@end

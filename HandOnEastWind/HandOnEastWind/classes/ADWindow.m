//
//  ADWindow.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-11.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "ADWindow.h"

@implementation ADWindow
{
    CGPoint startPoint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:[[[UIApplication sharedApplication] delegate] window]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:[[[UIApplication sharedApplication] delegate] window]];
    if (abs(currentPoint.x - startPoint.x) > 1) {
        
        CGFloat x = currentPoint.x - startPoint.x + self.frame.origin.x;
        
        if (x > 0) {
            x = 0;
        }
        
        self.frame = CGRectMake(x, 0, self.frame.size.width, self.frame.size.height);
    }
    startPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.frame.origin.x < -1 * self.frame.size.width / 2.5) {
        [UIView animateWithDuration:.2f animations:^{
            self.frame = CGRectMake(-1 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:.2f animations:^{
            self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }];
    }
}

@end

//
//  AdView.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-3-8.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "AdView.h"

@implementation AdView
{
    CGPoint startPoint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

+ (AdView *)sharedAdView:(CGRect)frame
{
    static AdView *adView = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        adView = [[self alloc] initWithFrame:frame];
        adView.userInteractionEnabled = YES;
    });
    return adView;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:self.superview];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self.superview];
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
    if (self.frame.origin.x < -1 * self.frame.size.width / 2) {
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

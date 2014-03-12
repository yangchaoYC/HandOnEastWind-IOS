//
//  NewsADAlertWindow.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-12.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NewsADAlertWindow.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface NewsADAlertWindow()
@property(nonatomic,strong)UIImageView *newsADImageView;
@end

@implementation NewsADAlertWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.windowLevel = UIWindowLevelAlert + 111;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        // Initialization code
        self.newsADImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 150.0f)];
        self.newsADImageView.layer.borderColor = [UIColor colorWithRed:170.0f / 255.0f green:130.0f / 255.0f blue:60.0f / 255.0f alpha:1.0f].CGColor;
        self.newsADImageView.layer.borderWidth = 2.0f;

        [self addSubview:self.newsADImageView];
        self.newsADImageView.center = self.center;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        CGRect frame = self.newsADImageView.frame;
        closeBtn.frame = CGRectMake(frame.origin.x + frame.size.width - 22.0f, frame.origin.y,22,22);
        [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:closeBtn aboveSubview:self.newsADImageView];
    }
    return self;
}

- (void)show
{
    [self.newsADImageView setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"image_default.png"]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = self;
    
    self.hidden = NO;
    [self makeKeyAndVisible];
    
    //2秒钟后消失
    [self performSelector:@selector(hide) withObject:self afterDelay:2.0f];
}

- (void)hide
{
    self.hidden = YES;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = nil;
}

- (void)dealloc
{
    self.newsADImageView = nil;
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

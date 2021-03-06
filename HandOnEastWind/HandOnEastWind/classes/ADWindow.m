//
//  ADWindow.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-11.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "ADWindow.h"
#import "FMDatabase.h"
#import "ADDownLoadManager.h"

static NSString *appLoadADKey = @"软件启动";

@interface ADWindow()
@property(nonatomic,strong)UIImageView *adImageView;
@property(nonatomic,strong)UIImageView *logoImageView;
@property(nonatomic,strong)UILabel *copyrightLabel;
@end

@implementation ADWindow
{
    CGPoint startPoint;
}

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define AD_CACHE_PATH [ITCACHE_PATH stringByAppendingPathComponent:@"AD_CACHE"]
- (void)show
{
    NSDictionary *adDic;
    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
    NSString *sqlStr = @"SELECT * FROM ad_cache WHERE node_title = ?";
    if ([db open])
    {
        [db beginTransaction];
        
        FMResultSet *rs = [db executeQuery:sqlStr,appLoadADKey];
        while ([rs next]) {
            adDic = @{@"nid": [rs objectForColumnName:@"nid"],
                      @"node_changed": [rs objectForColumnName:@"node_changed"],
                      @"node_title": [rs objectForColumnName:@"node_title"],
                      @"field_thumbnails": [rs objectForColumnName:@"field_thumbnails"]
                      };
            break;
        }
        
        [db commit];
    }
    [db close];
    
    if (adDic) {
        if (adDic) {
            if ([adDic objectForKey:@"field_thumbnails"] && ![[adDic objectForKey:@"field_thumbnails"] isEqualToString:@""]) {
                NSString *imageName = [ADDownLoadManager md5HexDigest:[adDic objectForKey:@"field_thumbnails"]];
                NSString *imagePath = [AD_CACHE_PATH stringByAppendingPathComponent:imageName];
                self.adImageView.image = [UIImage imageWithContentsOfFile:imagePath];
            }
            else
            {
            }
            
            [[ADDownLoadManager sharedManager] downLoadAD:adDic adKey:appLoadADKey];
            
        }
    }
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:241.0f/255.0f  blue:239.0f/255.0f  alpha:1];
        self.adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 384 + IS_IP5_SIZE)];
       // self.adImageView.center = self.center;
        [self addSubview:self.adImageView];
        
        self.logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 400 + IS_IP5_SIZE, 320, 40)];
        self.logoImageView.image = [UIImage imageNamed:@"logo.png"];
        [self addSubview:self.logoImageView];
        
        self.copyrightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 455 + IS_IP5_SIZE, 320, 20)];
        self.copyrightLabel.text = @"Copyright©2014 dfcm.cc.inc, All Rights Reserved";
        self.copyrightLabel.textAlignment = NSTextAlignmentCenter;
        self.copyrightLabel.backgroundColor = [UIColor clearColor];
        self.copyrightLabel.font = [UIFont fontWithName:@"ARIAL" size:8.0f];
        self.copyrightLabel.textColor = [UIColor colorWithRed:109.0f/255.0f green:109.0f/255.0f blue:109.0f/255.0f alpha:1];
        [self addSubview:self.copyrightLabel];
        
        
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

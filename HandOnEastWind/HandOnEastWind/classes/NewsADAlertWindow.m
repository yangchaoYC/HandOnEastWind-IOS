//
//  NewsADAlertWindow.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-12.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NewsADAlertWindow.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
#import "ADDownLoadManager.h"

@interface NewsADAlertWindow()
@property(nonatomic,strong)UIImageView *newsADImageView;
@end

@implementation NewsADAlertWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        // Initialization code
        self.newsADImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 150.0f)];
        self.newsADImageView.layer.borderColor = [UIColor colorWithRed:170.0f / 255.0f green:130.0f / 255.0f blue:60.0f / 255.0f alpha:1.0f].CGColor;
        self.newsADImageView.layer.borderWidth = 2.0f;

        [self addSubview:self.newsADImageView];
        self.newsADImageView.center = self.center;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = self.newsADImageView.frame;
        [closeBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(frame.origin.x + frame.size.width - 33.0f, frame.origin.y,33,33);
        [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:closeBtn aboveSubview:self.newsADImageView];
    }
    return self;
}

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define AD_CACHE_PATH [ITCACHE_PATH stringByAppendingPathComponent:@"AD_CACHE"]
- (void)show:(NSString *)key
{
    NSDictionary *adDic;
    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
    NSString *sqlStr = @"SELECT * FROM ad_cache WHERE node_title = ?";
    if ([db open])
    {
        [db beginTransaction];
        
        FMResultSet *rs = [db executeQuery:sqlStr,key];
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
        if ([adDic objectForKey:@"field_thumbnails"] && ![[adDic objectForKey:@"field_thumbnails"] isEqualToString:@""]) {
            NSString *imageName = [ADDownLoadManager md5HexDigest:[adDic objectForKey:@"field_thumbnails"]];
            NSString *imagePath = [AD_CACHE_PATH stringByAppendingPathComponent:imageName];
            self.newsADImageView.image = [UIImage imageWithContentsOfFile:imagePath];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.alertViewCache = self;
            self.hidden = NO;
            [self makeKeyAndVisible];
            //2秒钟后消失
            [self performSelector:@selector(hide) withObject:self afterDelay:3.0f];
            
        }
        else
        {
            [self hide];
        }
        
        [[ADDownLoadManager sharedManager] downLoadAD:adDic adKey:key];

    }
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
@end

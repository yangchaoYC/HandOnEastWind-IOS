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
#import "FMDatabase.h"
#import "AFHTTPRequestOperation.h"

@interface NewsADAlertWindow()
@property(nonatomic,strong)UIImageView *newsADImageView;
@property(nonatomic,strong)AFHTTPRequestOperation *request;
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
#define AD_BASE_URL [BASE_URL stringByAppendingString:@"mobile/adstart?nid=%d"]
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
        __weak NewsADAlertWindow *safe_self = self;
        [self.newsADImageView setImageWithURL:[NSURL URLWithString:[adDic objectForKey:@"field_thumbnails"]] placeholderImage:[UIImage imageNamed:@"image_default.png"]];
        
        NSString *urlString = [NSString stringWithFormat:AD_BASE_URL,[[adDic objectForKey:@"nid"] intValue]];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        self.request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        [self.request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
            id rs = [[NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil] objectAtIndex:0];
            NSString *serverVersion = [rs objectForKey:@"node_changed"];
            if ([serverVersion doubleValue] != [[adDic objectForKey:@"node_changed"] doubleValue]) {
                
                [safe_self.newsADImageView setImageWithURL:[NSURL URLWithString:[rs objectForKey:@"field_thumbnails"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    
                    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
                    NSString *sqlStr = @"UPDATE ad_cache SET node_changed = ? ,field_thumbnails = ? WHERE node_title = ?";
                    if ([db open])
                    {
                        
                        [db executeUpdate:sqlStr,[NSNumber numberWithDouble:[[rs objectForKey:@"node_changed"] doubleValue]],[rs objectForKey:@"field_thumbnails"],key];
                    }
                    [db close];
                    
                }];
                
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation,NSError *error){
            
        }];
        [self.request start];
    }

    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = self;
    
    self.hidden = NO;
    [self makeKeyAndVisible];
    
    //2秒钟后消失
    [self performSelector:@selector(hide) withObject:self afterDelay:3.0f];
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

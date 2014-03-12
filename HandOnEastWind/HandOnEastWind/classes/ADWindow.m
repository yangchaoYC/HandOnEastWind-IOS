//
//  ADWindow.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-11.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "ADWindow.h"
#import "UIImageView+WebCache.h"
#import "FMDatabase.h"
#import "AFHTTPRequestOperation.h"

static NSString *appLoadADKey = @"软件启动";

@interface ADWindow()
@property(nonatomic,strong)UIImageView *adImageView;
@end

@implementation ADWindow
{
    CGPoint startPoint;
}

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
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
        [self.adImageView setImageWithURL:[NSURL URLWithString:[adDic objectForKey:@"field_thumbnails"]] placeholderImage:nil];
    }
    
}

#define AD_BASE_URL [BASE_URL stringByAppendingString:@"mobile/adstart?nid=%d"]
- (void)updateAD
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
        
        NSString *urlString = [NSString stringWithFormat:AD_BASE_URL,[[adDic objectForKey:@"nid"] intValue]];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
            id rs = [[NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil] objectAtIndex:0];
            NSString *serverVersion = [rs objectForKey:@"node_changed"];
            if ([serverVersion doubleValue] != [[adDic objectForKey:@"node_changed"] doubleValue]) {
                
                [self.adImageView setImageWithURL:[NSURL URLWithString:[rs objectForKey:@"field_thumbnails"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    
                    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
                    NSString *sqlStr = @"UPDATE ad_cache SET node_changed = ? ,field_thumbnails = ? WHERE node_title = ?";
                    if ([db open])
                    {
                        
                        [db executeUpdate:sqlStr,[NSNumber numberWithDouble:[[rs objectForKey:@"node_changed"] doubleValue]],[rs objectForKey:@"field_thumbnails"],appLoadADKey];
                    }
                    [db close];
                    
                }];
                
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation,NSError *error){
            
        }];
        [request start];
        
    }

}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.adImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.adImageView.center = self.center;
        [self addSubview:self.adImageView];
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

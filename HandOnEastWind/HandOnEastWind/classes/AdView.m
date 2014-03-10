//
//  AdView.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-3-8.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "AdView.h"
#import "AFHTTPRequestOperation.h"

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

+ (AdView *)sharedAdView
{
    static AdView *adView = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        adView = [[[NSBundle mainBundle] loadNibNamed:@"ADView" owner:self options:nil] lastObject];
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

#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
- (void)setADViewImage
{
    //检查本地是否存在
    NSDictionary *adConfig = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ITCACHE_PATH,@"ADCONFIG"]];
    if (adConfig) {
        NSString *imagePath = [ITCACHE_PATH stringByAppendingPathComponent:@"ADIMAGE"];
        self.adImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        self.titleLabel.text = [adConfig objectForKey:@"title"];
    }
    
    //检查服务器的版本
    NSString *currentVersion = [adConfig objectForKey:@"version"];
    
    NSString *urlString = @"http://zhangshangdongfeng.demo.evebit.com/mobile/adstart?nid=1136";
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
        id rs = [[NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil] objectAtIndex:0];
        NSString *serverVersion = [rs objectForKey:@"node_changed"];
        if (![serverVersion isEqualToString:currentVersion]) {
            [self downLoadADImage : serverVersion title:[rs objectForKey:@"node_title"] urlString:[rs objectForKey:@"field_thumbnails"]];
        }
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        
    }];
    [request start];

}

- (void)downLoadADImage:(NSString *)serverVersion title:(NSString *)title urlString:(NSString *)imageURLString
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *path=[ITCACHE_PATH stringByAppendingPathComponent: @"ADIMAGE"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //下载成功
        NSDictionary *config = @{@"version": serverVersion,@"title":title};
        [config writeToFile:[ITCACHE_PATH stringByAppendingPathComponent:@"ADCONFIG"] atomically:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [operation start];
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

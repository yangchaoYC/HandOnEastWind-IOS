//
//  ADViewController.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-11.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "ADViewController.h"
#import "AFHTTPRequestOperation.h"

#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

@interface ADViewController ()

@end

@implementation ADViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //检查本地是否存在
    NSDictionary *adConfig = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ITCACHE_PATH,@"ADCONFIG"]];
    if (adConfig) {
        NSString *imagePath = [ITCACHE_PATH stringByAppendingPathComponent:@"ADIMAGE"];
        self.adImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        self.titleLabel.text = [adConfig objectForKey:@"title"];
    }
}

- (void)awakeFromNib
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y + 20.0f, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
        self.adImageView.frame = CGRectMake(self.adImageView.frame.origin.x, self.adImageView.frame.origin.y + 20.0f, self.adImageView.frame.size.width, self.adImageView.frame.size.height - 20.0f);
    }
}

- (void)updateAD
{
    NSDictionary *adConfig = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ITCACHE_PATH,@"ADCONFIG"]];
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
        
        self.adImageView.image = [UIImage imageWithContentsOfFile:path];
        self.titleLabel.text =title;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [operation start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

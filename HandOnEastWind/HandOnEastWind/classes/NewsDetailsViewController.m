//
//  NewsDetailsViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NewsDetailsViewController.h"
#import "NewsModel.h"
#import "RegexKitLite.h"
#import <ShareSDK/ShareSDK.h>

@interface NewsDetailsViewController ()

@end

@implementation NewsDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define URL_BASE @"http://zhangshangdongfeng.demo.evebit.com"
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    int fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:@"FONTSIZE"] intValue];
    self.changeFontsizeControl.selectedSegmentIndex = fontSize;
    
    //加载本地模版
    NSURL *baseURL = [NSURL URLWithString:URL_BASE];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"news_template" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    //进行数据添加
    html = [html stringByReplacingOccurrencesOfString:@"{title}" withString:self.newsItem.node_title];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.newsItem.node_created doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    html = [html stringByReplacingOccurrencesOfString:@"{time}" withString:destDateString];
    
    BOOL hasImage = [[[NSUserDefaults standardUserDefaults] valueForKey:@"HASIMAGE"] boolValue];
    
    html = [html stringByReplacingOccurrencesOfString:@"{Content}" withString:self.newsItem.body_1];

    if (!hasImage) {
        NSString *regexString       = @"<img[^>]+alt=\"([^>]+)\"[^>]*>";
        NSString *replaceWithString = @" ";
        html = [html stringByReplacingOccurrencesOfRegex:regexString withString:replaceWithString];
    }
    switch ([self getFontsize]) {
        case 0:
            html = [html stringByReplacingOccurrencesOfString:@"{fontSize}" withString:@"10pt"];
            break;
        case 1:
            html = [html stringByReplacingOccurrencesOfString:@"{fontSize}" withString:@"15pt"];
            break;
        case 2:
            html = [html stringByReplacingOccurrencesOfString:@"{fontSize}" withString:@"20pt"];
            break;
        default:
            break;
    }
    
    [self.newsDetailWebView loadHTMLString:html baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeFontsize:(UISegmentedControl *)sender
{
    NSInteger Index = sender.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:Index] forKey:@"FONTSIZE"];
    NSString *changeFontSizeString = [NSString stringWithFormat:@"changeFontSize(%d);",Index];
    [self.newsDetailWebView stringByEvaluatingJavaScriptFromString:changeFontSizeString];
}

- (int)getFontsize
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"FONTSIZE"] intValue];
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareBtnClick:(id)sender
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

@end

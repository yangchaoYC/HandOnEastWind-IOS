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
#import "UMSocial.h"

#import "AKSegmentedControl.h"

@interface NewsDetailsViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) AKSegmentedControl *changeFontsizeControl;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.changeFontsizeControl = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(216, 10 , 92, 28)];
    [self.changeFontsizeControl addTarget:self action:@selector(changeFontsize:) forControlEvents:UIControlEventValueChanged];
    [self.changeFontsizeControl setSegmentedControlMode:AKSegmentedControlModeSticky];
    [self setupSegmentedControl:self.changeFontsizeControl];
    [self.bottomBar addSubview:self.changeFontsizeControl];
    
    //加载本地模版
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"news_template" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    //进行数据添加
    html = [html stringByReplacingOccurrencesOfString:@"{title}" withString:self.newsItem.node_title];
    html = [html stringByReplacingOccurrencesOfString:@"{meidaSting}" withString:self.newsItem.field_newsfrom];
    
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
    
    self.newsDetailWebView.delegate = self;
    [self.newsDetailWebView loadHTMLString:html baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *changeFontSizeString = [NSString stringWithFormat:@"changeFontSize(%d);",[self getFontsize]];
    [self.newsDetailWebView stringByEvaluatingJavaScriptFromString:changeFontSizeString];
}

- (void)setupSegmentedControl:(AKSegmentedControl *)segmentedControl
{
    segmentedControl.clipsToBounds = YES;
    segmentedControl.layer.borderColor = [UIColor whiteColor].CGColor;
    segmentedControl.layer.borderWidth = 1;
    segmentedControl.layer.cornerRadius = 3.0f;
    [segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    [segmentedControl setSeparatorImage:[self createImageWithColor:[UIColor whiteColor]]];
    
    [segmentedControl setButtonsArray:@[[self createButtonWithTitle:@"小"],
                                        [self createButtonWithTitle:@"中"],
                                        [self createButtonWithTitle:@"大"]]];
    
    int fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:@"FONTSIZE"] intValue];
    [segmentedControl setSelectedIndex:fontSize];
}

- (UIButton *)createButtonWithTitle:(NSString *)titleString
{
   // UIImage *buttonBackgroundImagePressed = [self createImageWithColor:[UIColor greenColor]];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //[btn setBackgroundImage:buttonBackgroundImagePressed forState:UIControlStateHighlighted];
    //[btn setBackgroundImage:buttonBackgroundImagePressed forState:UIControlStateSelected];
    //[btn setBackgroundImage:buttonBackgroundImagePressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [btn setTitle:titleString forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    return btn;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeFontsize:(AKSegmentedControl *)sender
{
    NSInteger Index = sender.selectedIndexes.firstIndex;
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
   
     NSString *shareString = [NSString stringWithFormat:@"我在掌上东风应用中看到一条信息,你也来看看把!---%@news/%@.html",BASE_URL,self.newsItem.nid];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"533a661656240b29e8017e88"
                                      shareText:shareString
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:nil];
   
    
  //  NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    
    
   
    //构造分享内容
    /*
    id<ISSContent> publishContent = [ShareSDK content:shareString
                                       defaultContent:@"东风传媒为您提供最新的信息"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:self.newsItem.node_title
                                                  url:@"http://www.dfcm.cc/"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:NO
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
    */
}

@end

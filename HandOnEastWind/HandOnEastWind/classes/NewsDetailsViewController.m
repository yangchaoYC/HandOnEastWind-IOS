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
#import <ShareSDK/ShareSDK.h>
#import "AKSegmentedControl.h"

@interface NewsDetailsViewController ()
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
            html = [html stringByReplacingOccurrencesOfString:@"{fontSize}" withString:@"13pt"];
            break;
        case 1:
            html = [html stringByReplacingOccurrencesOfString:@"{fontSize}" withString:@"14pt"];
            break;
        case 2:
            html = [html stringByReplacingOccurrencesOfString:@"{fontSize}" withString:@"17pt"];
            break;
        default:
            break;
    }
    
    [self.newsDetailWebView loadHTMLString:html baseURL:baseURL];
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
    
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    return btn;
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
    /*
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"507fcab25270157b37000010"
                                      shareText:@"你要分享的文字"
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToSms,UMShareToEmail,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:nil];
    */
    
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
    
}

@end

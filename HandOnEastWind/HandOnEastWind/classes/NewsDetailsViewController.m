//
//  NewsDetailsViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NewsDetailsViewController.h"
#import "NewsModel.h"

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
    
    
    NSString *regexString       = @"<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
    NSString *replaceWithString = @"";
    html = [html stringByReplacingOccurrencesOfRegex:regexString withString:replaceWithString];
    
    BOOL hasImage = [[[NSUserDefaults standardUserDefaults] valueForKey:@"HASIMAGE"] boolValue];
    if (hasImage) {
        html = [html stringByReplacingOccurrencesOfString:@"{Content}" withString:self.newsItem.body_1];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"{Content}" withString:self.newsItem.body_2];
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

- (IBAction)shareBtnClick:(id)sender {
}

@end

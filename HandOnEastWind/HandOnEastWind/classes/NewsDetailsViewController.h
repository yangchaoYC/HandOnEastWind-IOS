//
//  NewsDetailsViewController.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewsModel;

@interface NewsDetailsViewController : UIViewController
    
@property (weak, nonatomic) IBOutlet UIWebView *newsDetailWebView;
@property (strong,nonatomic)NewsModel *newsItem;
    
- (IBAction)backBtnClick:(id)sender;
@end

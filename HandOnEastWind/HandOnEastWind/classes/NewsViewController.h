//
//  NewsViewController.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NavigationScrollView;

@interface NewsViewController : UIViewController
@property (weak, nonatomic) IBOutlet NavigationScrollView *navigationScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *newsListContainer;

- (IBAction)chooseBtnClicked:(id)sender;
- (void)refreshContent:(NSString *)columnName;
@end

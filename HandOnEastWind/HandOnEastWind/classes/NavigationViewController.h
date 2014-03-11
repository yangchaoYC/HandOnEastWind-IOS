//
//  NavigationViewController.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *navigationTableView;
- (IBAction)showPartners:(id)sender;
@end

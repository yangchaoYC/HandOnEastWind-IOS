//
//  HomeViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomTabBarView.h"

@interface HomeViewController ()<CustomTabBarViewSelectedDelegate>

@end

@implementation HomeViewController

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
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = YES;
    [self setSelectedIndex:1];
	// Do any additional setup after loading the view.
    /*
    self.tabBar.hidden = YES;
    
    CustomTabBarView *tabBar = [[[NSBundle mainBundle] loadNibNamed:@"CustomTabBarView" owner:self options:nil] lastObject];
    tabBar.frame = CGRectMake(0, 64+455, tabBar.bounds.size.width, tabBar.bounds.size.height);
    tabBar.selectedDelegate = self;
    [self.view addSubview:tabBar];
    
    [self selectedTabBarAtIndex:0];
     */
}

- (void)selectedTabBarAtIndex:(NSInteger)index_
{
    [self setSelectedIndex:index_];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

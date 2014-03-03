//
//  HomeViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomTabBarView.h"
#import "NewsViewController.h"

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
    
    self.hidesBottomBarWhenPushed = YES;
	// Do any additional setup after loading the view.
    //self.tabBar.hidden = YES;
    
    /*
    CustomTabBarView *tabBar = [[[NSBundle mainBundle] loadNibNamed:@"CustomTabBarView" owner:self options:nil] lastObject];
    tabBar.frame = self.tabBar.frame;
    tabBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    tabBar.selectedDelegate = self;
    [self.view addSubview:tabBar];
    
    [self selectedTabBarAtIndex:1];
    
    
    NSLog(@"%@", [self.view subviews]);
    for (UIView *v in [self.view subviews]) {
        if ([v isKindOfClass:[UITabBar class]] || [v isKindOfClass:[CustomTabBarView class]]) {
            
        }
        else
        {
            v.frame = CGRectMake(0, 0, 320, 480 - 49);
            v.autoresizingMask = UIViewAutoresizingNone;

        }
        
    }
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectNavigation:) name:@"SelectNavigation" object:nil];
}

- (void)selectNavigation:(NSNotification *)notif
{
    [self selectedTabBarAtIndex:1];
    
    for (UIViewController *controller in [self viewControllers]) {
        if ([controller isKindOfClass:[NewsViewController class]]) {
            [(NewsViewController *)controller refreshContent:notif.object];
        }
    }
}

- (void)selectedTabBarAtIndex:(NSInteger)index_
{
    [self setSelectedIndex:index_];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"SelectNavigation"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

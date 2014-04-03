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
#import "NavigationViewController.h"

@interface HomeViewController ()
@property(nonatomic,strong)CustomTabBarView *customTabBar;
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
    
    self.customTabBar = [[[NSBundle mainBundle] loadNibNamed:@"CustomTabBarView" owner:self options:nil] lastObject];
    self.customTabBar.frame = self.tabBar.frame;
    self.customTabBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    __unsafe_unretained HomeViewController *safe_self = self;
    self.customTabBar.selectdCallBackBlock = ^(int index){
        [safe_self setSelectedIndex:index];
    };
    [self.view insertSubview:self.customTabBar aboveSubview:self.tabBar];
    
    for (UIViewController *controller in [self viewControllers]) {
        if ([controller isKindOfClass:[NavigationViewController class]]) {
            [(NavigationViewController *)controller setSelectNavigationCallbackBlock:^(NSString *navigationString) {
                [safe_self setSelectedIndex:1];
                for (UIViewController *controller in [safe_self viewControllers]) {
                    if ([controller isKindOfClass:[NewsViewController class]]) {
                        [(NewsViewController *)controller refreshContent:navigationString];
                    }
                    break;
                }
            }];
            break;
        }
    }

}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    for (UIImageView *item in [self.customTabBar subviews]) {
        if (item.tag == selectedIndex) {
            [item setHighlighted:YES];
        }
        else
        {
            [item setHighlighted:NO];
        }
    }
    [self.customTabBar setCurrentSelectedIndex:selectedIndex];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  NavigationViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NavigationViewController.h"
#import "AppDelegate.h"
#import "NavigationCell.h"
#import "AppDelegate.h"
#import "ADWindow.h"
#import "PartnersAlertWindow.h"

@interface NavigationViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)NSArray *navigationsArray;
@end

@implementation NavigationViewController

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
    
    
    self.navigationsArray = @[@"东风汽车报",@"东风",@"汽车之旅",@"汽车科技",@"装备维修技术"];
    [self.navigationTableView reloadData];
    
    UISwipeGestureRecognizer *ges = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showADView:)];
    ges.direction = UISwipeGestureRecognizerDirectionRight;
    [self.navigationTableView addGestureRecognizer:ges];
}

- (void)showADView:(UISwipeGestureRecognizer *)ges
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ADWindow *adWindow = [appDelegate adWindow];
    [adWindow show];
    [UIView animateWithDuration:.5f animations:^{
        adWindow.frame = CGRectMake(0, 0, adWindow.frame.size.width, adWindow.frame.size.height);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.navigationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"NavigationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NavigationCell *navCell = (NavigationCell *)cell;
    
    navCell.titleLabel.text = [self.navigationsArray objectAtIndex:indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            navCell.detailLabel.text = @"展示集团风采，弘扬精神文明";
            navCell.iconImageView.image = [UIImage imageNamed:@"nav_1.png"];
            break;
        case 1:
            navCell.detailLabel.text = @"一个企业的文化与创造";
            navCell.iconImageView.image = [UIImage imageNamed:@"nav_2.png"];
            break;
        case 2:
            navCell.detailLabel.text = @"品鉴魅力汽车 畅享快乐之旅";
            navCell.iconImageView.image = [UIImage imageNamed:@"nav_3.png"];
            break;
        case 3:
            navCell.detailLabel.text = @"中国汽车产业和汽车科技自主创新的重要发言者";
            navCell.iconImageView.image = [UIImage imageNamed:@"nav_4.png"];
            break;
        case 4:
            navCell.detailLabel.text = @"中国汽车装备第一刊";
            navCell.iconImageView.image = [UIImage imageNamed:@"nav_5.png"];
            break;
        default:
            break;
    }
   
    return cell;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectNavigationCallbackBlock([self.navigationsArray objectAtIndex:indexPath.row]);
}

- (IBAction)showPartners:(id)sender
{
    PartnersAlertWindow *alertView = [[PartnersAlertWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertView show];
}
@end

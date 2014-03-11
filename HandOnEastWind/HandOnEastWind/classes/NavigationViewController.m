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
    return 95.0f;
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
    navCell.detailLabel.text = @"展示集团风采，弘扬精神文明";
    navCell.iconImageView.image = [UIImage imageNamed:@"navigation_icon.png"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectNavigation" object:[self.navigationsArray objectAtIndex:indexPath.row]];
}

- (IBAction)showPartners:(id)sender
{
    PartnersAlertWindow *alertView = [[PartnersAlertWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertView show];
}
@end

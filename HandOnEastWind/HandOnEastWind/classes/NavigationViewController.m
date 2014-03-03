//
//  NavigationViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NavigationViewController.h"
#import "AppDelegate.h"

@interface NavigationViewController ()

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectNavigation:(id)sender
{
    
    NSString *columName = @"";
    switch ([sender tag]) {
        case 0:
            columName = @"东风汽车报";
            break;
        case 1:
            columName = @"东风";
            break;
        case 2:
            columName = @"汽车之旅";
            break;
        case 3:
            columName = @"汽车科技";
            break;
        case 4:
            columName = @"装备维修技术";
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectNavigation" object:columName];

}
@end

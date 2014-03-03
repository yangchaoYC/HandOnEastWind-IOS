//
//  SettingViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SettingViewController

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [cell.contentView addSubview:titleLabel];
    
    switch (indexPath.row) {
        case 0:
        {
            titleLabel.text = @"字体大小";
            UISegmentedControl *fontSizeControl = [[UISegmentedControl alloc] initWithItems:@[@"小",@"中",@"大"]];
            [fontSizeControl addTarget:self action:@selector(changeFontsize:) forControlEvents:UIControlEventValueChanged];  //添加委托方法
            fontSizeControl.frame = CGRectMake(200, 0, 100, 30);
            fontSizeControl.selectedSegmentIndex = [self getFontsize];
            [cell.contentView addSubview:fontSizeControl];
        }
            break;
        case 1:
        {
            titleLabel.text = @"无图模式";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, 0, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 1;
            [sw setOn:[self getHasImage]];
            [cell.contentView addSubview:sw];
        }
            break;
        case 2:
        {
            titleLabel.text = @"推送设置";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, 0, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 2;
            [sw setOn:[self getHasPush]];
            [cell.contentView addSubview:sw];
        }
            break;
        case 3:
        {
            titleLabel.text = @"推送铃声";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, 0, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 3;
            [sw setOn:[self getHasPushRing]];
            [cell.contentView addSubview:sw];
        }
            break;
        case 4:
        {
            titleLabel.text = @"清除缓存";
            UILabel *cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 30)];
            cacheLabel.text = @"缓存大小。。。。。";
            [cell.contentView addSubview:cacheLabel];
        }
            break;
        case 5:
        {
            titleLabel.text = @"字体大小";
        }
            break;
        case 6:
        {
            titleLabel.text = @"字体大小";
        }
            break;
        case 7:
        {
            titleLabel.text = @"字体大小";
        }
            break;
        default:
            break;
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 4:
            //清除缓存
            break;
        case 5:
            //关于
            break;
        case 6:
            //免责声明
            break;
        case 7:
            //检查更新
            break;
        default:
            break;
    }
}

- (void)changeFontsize:(UISegmentedControl *)control
{
    NSInteger Index = control.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:Index] forKey:@"FONTSIZE"];
}

- (void)switchAction:(UISwitch *)switch_
{
    switch (switch_.tag) {
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:switch_.on] forKey:@"HASIMAGE"];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:switch_.on] forKey:@"HASPUSH"];
            break;
        case 3:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:switch_.on] forKey:@"HASPUSHRING"];
            break;
        default:
            break;
    }
}

- (int)getFontsize
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"FONTSIZE"] intValue];
}

- (BOOL)getHasImage
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"HASIMAGE"] boolValue];
}

- (BOOL)getHasPush
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"HASPUSH"] boolValue];

}

- (BOOL)getHasPushRing
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"HASPUSHRING"] boolValue];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

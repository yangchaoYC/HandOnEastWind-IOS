//
//  SettingViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "SettingViewController.h"
#include <sys/stat.h>
#include <dirent.h>
#import "FMDatabase.h"
#import "AKSegmentedControl.h"
#import "DirectionsViewController.h"
#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define AD_CACHE_PATH [ITCACHE_PATH stringByAppendingPathComponent:@"AD_CACHE"]

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSDictionary *version;
}

@property(nonatomic,strong)UIAlertView *alert;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.settingTableView reloadData];
    [MobClick beginLogPageView:@"PageOne"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.settingTableView.bounces = NO;
    self.settingTableView.showsVerticalScrollIndicator = NO;
    
    self.view_Table.frame = CGRectMake(9, 70 + IS_IP5, 302, 265);
    self.activity.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    
    UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIFont *Font_ForgetPwd = [UIFont fontWithName:@"ARIAL" size:13.0f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 100, 14)];
    titleLabel.font = Font_ForgetPwd;
    
    [cell.contentView addSubview:titleLabel];
    UIView *separator = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 300, 1)];
    separator.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f  blue:200.0f/255.0f  alpha:1];
    [cell.contentView addSubview:separator];
    switch (indexPath.row) {
        case 0:
        {
            titleLabel.text = @"字体大小";            
            
            AKSegmentedControl *changeFontsizeControl = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(190, 8 , 100, 28)];
            [changeFontsizeControl addTarget:self action:@selector(changeFontsize:) forControlEvents:UIControlEventValueChanged];
            [changeFontsizeControl setSegmentedControlMode:AKSegmentedControlModeSticky];
            [self setupSegmentedControl:changeFontsizeControl];
            [cell.contentView addSubview:changeFontsizeControl];
        }
            break;
        case 1:
        {
            titleLabel.text = @"无图模式";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(190, 8, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 1;
            [sw setOn:![self getHasImage]];
            if (![[NSUserDefaults standardUserDefaults] valueForKey:@"HASIMAGE"]) {
                [sw setOn:NO];
            }
            [cell.contentView addSubview:sw];
            
        }
            break;
            /*
        case 2:
        {
            titleLabel.text = @"推送设置";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, 8, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 2;
            [cell.contentView addSubview:sw];
            [sw setOn:[[UIApplication sharedApplication] enabledRemoteNotificationTypes]];
        }
            break;
        case 3:
        {
            titleLabel.text = @"推送铃声";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, 8, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 3;
            [sw setOn:[self getHasPushRing]];
            [cell.contentView addSubview:sw];
        }
            break;
             */
        case 2:
        {
            titleLabel.text = @"清除缓存";
            
            long long imageCacheSize = [self folderSizeAtPath:[[ITCACHE_PATH stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"] cStringUsingEncoding:NSUTF8StringEncoding]] + [self folderSizeAtPath:[AD_CACHE_PATH cStringUsingEncoding:NSUTF8StringEncoding]];
            
            long long sumSize = imageCacheSize;
            
            UILabel *cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 8, 120, 30)];
            cacheLabel.font = [UIFont systemFontOfSize:14.0f];
            cacheLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f  blue:200.0f/255.0f  alpha:1];
            cacheLabel.text = [NSString stringWithFormat:@"缓存大小 %.2f M",sumSize / 1024.0f / 1024.0f];
            [cell.contentView addSubview:cacheLabel];
        }
            break;
        case 3:
        {
            titleLabel.text = @"关于";
        }
            break;
        case 4:
        {
            titleLabel.text = @"免责声明";
        }
            break;
        case 5:
        {
            titleLabel.text = @"检查更新";
            
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        //    NSLog(@"%@",version);
            
            UILabel *cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 8, 120, 30)];
            cacheLabel.font = [UIFont systemFontOfSize:14.0f];
            cacheLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f  blue:200.0f/255.0f  alpha:1];
            cacheLabel.text = [NSString stringWithFormat:@"当前版本 %@ ",version];
            [cell.contentView addSubview:cacheLabel];
            
        }
            break;
        default:
            break;
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)setupSegmentedControl:(AKSegmentedControl *)segmentedControl
{
    segmentedControl.clipsToBounds = YES;
    segmentedControl.layer.borderColor = [UIColor grayColor].CGColor;
    segmentedControl.layer.borderWidth = 1;
    segmentedControl.layer.cornerRadius = 3.0f;
    [segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    [segmentedControl setSeparatorImage:[self createImageWithColor:[UIColor grayColor]]];
    
    [segmentedControl setButtonsArray:@[[self createButtonWithTitle:@"小"],
                                                  [self createButtonWithTitle:@"中"],
                                                  [self createButtonWithTitle:@"大"]]];
    
    int fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:@"FONTSIZE"] intValue];
    [segmentedControl setSelectedIndex:fontSize];
}

- (UIButton *)createButtonWithTitle:(NSString *)titleString
{
    UIImage *buttonBackgroundImagePressed = [self createImageWithColor:[UIColor grayColor]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setBackgroundImage:buttonBackgroundImagePressed forState:UIControlStateHighlighted];
    [btn setBackgroundImage:buttonBackgroundImagePressed forState:UIControlStateSelected];
    [btn setBackgroundImage:buttonBackgroundImagePressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [btn setTitle:titleString forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    return btn;
}

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (CGFloat)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (long long)folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        int folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    return folderSize;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 2:
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            NSArray *fileList = [fileManager contentsOfDirectoryAtPath:ITCACHE_PATH error:&error];
            for (NSString *fileName in fileList) {
                NSString* fileAbsolutePath = [ITCACHE_PATH stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:fileAbsolutePath error:nil];
            }
            
            fileList = [fileManager contentsOfDirectoryAtPath:AD_CACHE_PATH error:&error];
            for (NSString *fileName in fileList) {
                NSString* fileAbsolutePath = [AD_CACHE_PATH stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:fileAbsolutePath error:nil];
            }
 
            
            FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
            if ([db open])
            {
                [db beginTransaction];
                [db executeUpdate:@"DELETE FROM news"];
                [db executeUpdate:@"DELETE FROM update_log"];
                [db executeUpdate:@"UPDATE ad_cache SET node_changed = 0 ,field_thumbnails = ''"];
                [db commit];
            }
            [db close];
            
            [self.settingTableView reloadData];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"清除缓存成功!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 3:
            //关于
            
            [self performSegueWithIdentifier:@"directions" sender:@"关于"];
            
            break;
        case 4:
            //免责声明
            [self performSegueWithIdentifier:@"directions" sender:@"免责声明"];
            break;
        case 5:
            //检查更新
        {
            
            self.activity.hidden = NO;
            [self.activity startAnimating];
            self.activity.hidesWhenStopped = YES;
            [MobClick checkUpdateWithDelegate:self selector:@selector(Update:)];

        }
            
            break;
        default:
            break;
    }
}

-(void)Update:(NSDictionary *)info
{
    
    [self.activity stopAnimating];
    version = info;
    
    NSLog(@"%@",info);
    NSString *update = [NSString stringWithFormat:@"%@",[version objectForKey:@"update"]];
      if ([update isEqualToString:@"NO"]) {
        _alert = [[UIAlertView alloc]initWithTitle:@"当前版本是最新" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [_alert show];
    }
    else if([update isEqualToString:@"YES"])
    {
        NSString *title = [NSString stringWithFormat:@"有可用的新版本%@",[version objectForKey:@"version"]];
        NSString *message = [NSString stringWithFormat:@"%@",[version objectForKey:@"update_log"]];

         _alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"忽略此版本" otherButtonTitles:@"访问 Store",nil];
        [_alert show];
        
    }
    else
    {
        _alert = [[UIAlertView alloc]initWithTitle:@"超时，请稍后再试" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [_alert show];
    }
    
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [_alert removeFromSuperview];
            break;
        case 1:
            [self updateURL];
            break;
        default:
            break;
    }
}

-(void)updateURL
{
    NSLog(@"%@",[version objectForKey:@"path"]);
    NSString *URL = [NSString stringWithFormat:@"%@",[version objectForKey:@"path"]];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:URL]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *send = segue.destinationViewController;
    if ([send respondsToSelector:@selector(setKey:)]) {
        [send setValue:sender forKey:@"key"];
    }
}

- (void)changeFontsize:(AKSegmentedControl *)control
{
    NSInteger Index = control.selectedIndexes.firstIndex;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:Index] forKey:@"FONTSIZE"];
}

- (void)switchAction:(UISwitch *)switch_
{
    switch (switch_.tag) {
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!switch_.on] forKey:@"HASIMAGE"];
            break;
        case 2:
            if (!switch_.on) {
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }
            else
            {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            }
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

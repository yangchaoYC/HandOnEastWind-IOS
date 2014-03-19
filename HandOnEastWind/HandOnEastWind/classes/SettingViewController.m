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

#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define AD_CACHE_PATH [ITCACHE_PATH stringByAppendingPathComponent:@"AD_CACHE"]

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.settingTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.settingTableView.bounces = NO;
    self.settingTableView.showsVerticalScrollIndicator = NO;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
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
            UISegmentedControl *fontSizeControl = [[UISegmentedControl alloc] initWithItems:@[@"小",@"中",@"大"]];
            [fontSizeControl addTarget:self action:@selector(changeFontsize:) forControlEvents:UIControlEventValueChanged];  //添加委托方法
            fontSizeControl.frame = CGRectMake(190, 8, 100, 30);
            fontSizeControl.selectedSegmentIndex = [self getFontsize];
            fontSizeControl.tintColor = [UIColor colorWithRed:74.0f/255.0f green:213.0f/255.0f blue:98.0f/255.0f alpha:1];
            [cell.contentView addSubview:fontSizeControl];
        }
            break;
        case 1:
        {
            titleLabel.text = @"无图模式";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, 8, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 1;
            [sw setOn:![self getHasImage]];
            [cell.contentView addSubview:sw];
        }
            break;
        case 2:
        {
            titleLabel.text = @"推送设置";
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, 8, 50, 30)];
            [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            sw.tag = 2;
            [sw setOn:[self getHasPush]];
            [cell.contentView addSubview:sw];
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
        case 4:
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
        case 5:
        {
            titleLabel.text = @"关于";
        }
            break;
        case 6:
        {
            titleLabel.text = @"免责声明";
        }
            break;
        case 7:
        {
            titleLabel.text = @"检查更新";
        }
            break;
        default:
            break;
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
        case 4:
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
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!switch_.on] forKey:@"HASIMAGE"];
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

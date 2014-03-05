//
//  NewsViewController.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NewsViewController.h"

#import "NavigationScrollView.h"
#import "PullTableView.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "NewsModel.h"
#import "NewsCell.h"
#import "NewsFocusCell.h"
#import "UIImageView+WebCache.h"

@interface NewsViewController ()<UIScrollViewDelegate,NavigationScrollViewSlectedDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *navigationsArray;
@property(nonatomic,strong)NSMutableArray *newsListTableViewsArray;
@property(nonatomic,assign)int currentSelectedNavIndex;
@property (strong, nonatomic)NSString *columnName;

@end

@implementation NewsViewController

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
- (void)initDatabase
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]]) {
        FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cache" ofType:@"sql" ];
        NSError *error;
        NSString *sqlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        NSArray *sqls = [sqlStr componentsSeparatedByString:@"\n"];
        if ([db open])
        {
            [db beginTransaction];
            for (int i=0; i<sqls.count; i++) {
                [db executeUpdate:[sqls objectAtIndex:i]];
            }
            [db commit];
        }
    };
}

- (NSInteger)getNavID:(NSString *)navName_
{
    int navID_ = 0;
    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
    NSString *sqlStr = @"SELECT * FROM nav_id_map WHERE nav_name = ?";
    if ([db open])
    {
        [db beginTransaction];
        
        FMResultSet *rs = [db executeQuery:sqlStr,navName_];
        while ([rs next]) {
            navID_ = [rs intForColumn:@"nav_id"];
        }
        
        [db commit];
    }
    
    return navID_;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)chooseBtnClicked:(id)sender
{
    
}

- (void)refreshContent:(NSString *)columnName
{
    NSDictionary *columnsDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"navigations" ofType:@"txt"]]
                                                               options:NSJSONReadingAllowFragments error:nil];
    
    if ([columnName isEqualToString:self.columnName]) {
        return;
    }
    else
    {
        self.currentSelectedNavIndex = 0;
        [self.navigationScrollView selectNavigationAtIndex:self.currentSelectedNavIndex];
        self.navigationScrollView.selectedDelegate = self;
        
        self.columnName = columnName;
        
        for (UIView *v in [self.navigationScrollView subviews]) {
            [v removeFromSuperview];
        }
        for (UIView *v in self.newsListTableViewsArray) {
            [v removeFromSuperview];
        }
        self.navigationsArray = [columnsDic objectForKey:self.columnName];
        self.newsListTableViewsArray = [NSMutableArray array];

        [self.navigationScrollView initNavigations:self.navigationsArray];
        
        //3.5寸屏幕
        if (self.view.bounds.size.height <= 480.0f) {
            self.newsListContainer.frame = CGRectMake(self.newsListContainer.frame.origin.x,
                                                      self.newsListContainer.frame.origin.y,
                                                      self.newsListContainer.frame.size.width,
                                                      370.0f);
        }
        
        for (int i=0; i<self.navigationsArray.count; i++) {
            PullTableView *newsListTableView = [[PullTableView alloc] initWithFrame:CGRectMake(self.newsListContainer.frame.size.width * i, 0, self.newsListContainer.frame.size.width, self.newsListContainer.frame.size.height)];
            newsListTableView.delegate = self;
            newsListTableView.dataSource = self;
            newsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            newsListTableView.navName = [self.navigationsArray objectAtIndex:i];
            newsListTableView.navID = [self getNavID:newsListTableView.navName];
            
            [self.newsListContainer addSubview:newsListTableView];
            [self.newsListTableViewsArray addObject:newsListTableView];
            
            if (!i) {
                [newsListTableView autoRefresh];
            }
        }

        self.newsListContainer.pagingEnabled = YES;
        self.newsListContainer.bounces = NO;
        [self.newsListContainer setContentSize:CGSizeMake(self.newsListContainer.frame.size.width * self.navigationsArray.count, self.newsListContainer.frame.size.height)];
        
        [self.navigationScrollView selectNavigationAtIndex:self.currentSelectedNavIndex];
    }
}

- (void)viewDidLoad
{    
    [self initDatabase];
    [super viewDidLoad];
    
    if (!self.columnName) {
        [self refreshContent:@"东风汽车报"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.newsListContainer) {
        [self.navigationScrollView updateAttentionViewFrame:scrollView.contentOffset.x];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.newsListContainer) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (self.currentSelectedNavIndex != currentPage) {
            [self.navigationScrollView selectNavigationAtIndex:currentPage];
        }
        self.newsListContainer.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.newsListContainer) {
        if (decelerate) {
            self.newsListContainer.userInteractionEnabled = NO;
        }
    }
}

- (void)selectedNavigationItemAtIndex:(int)index_
{
    self.currentSelectedNavIndex = index_;
    [self.newsListContainer setContentOffset:CGPointMake(320.0f * index_, 0)];
    
    PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:index_];
    [newsListTableView autoRefresh];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[(PullTableView *)tableView dataArray] count];
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        if (indexPath.row == 0) {
            return 205.0f;
        }
        else return 70.0f;
    }

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *newsCellIdentifier = @"newsCell";
    static NSString *newsFocusCellIdentifier = @"newsFocusCell";
    
    NewsModel *newsItem = [[(PullTableView *)tableView dataArray] objectAtIndex:indexPath.row];

    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:newsFocusCellIdentifier];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewsFocusCell" owner:self options:nil] lastObject];
        }
        
        [[(NewsFocusCell *)cell focusImageView] setImageWithURL:[NSURL URLWithString:newsItem.field_thumbnails] placeholderImage:nil];
        
        [(NewsFocusCell *)cell labelTitle].text = newsItem.node_title;
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:newsCellIdentifier];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:self options:nil] lastObject];
        }
        
        [[(NewsCell *)cell newsIconImageView] setImageWithURL:[NSURL URLWithString:newsItem.field_thumbnails] placeholderImage:nil];
        [(NewsCell *)cell labelTitle].text = newsItem.node_title;
        [(NewsCell *)cell labelContent].text = newsItem.field_summary;
        [(NewsCell *)cell labelSource].text = newsItem.field_newsfrom;
        NSTimeInterval dateTime = [newsItem.node_created doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTime];
        [(NewsCell *)cell labelDate].text = [self stringFromDate:date];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel *newsItem = [[(PullTableView *)tableView dataArray] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"NewsDetails" sender:newsItem];
}
                               
- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *send = [segue destinationViewController];
    if ([send respondsToSelector:@selector(setNewsItem:)]) {
        [send setValue:sender forKey:@"newsItem"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

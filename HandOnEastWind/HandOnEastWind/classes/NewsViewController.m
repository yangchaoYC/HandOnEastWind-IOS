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

@interface NewsViewController ()<UIScrollViewDelegate,NavigationScrollViewSlectedDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *navigationsArray;
@property(nonatomic,strong)NSMutableArray *newsListTableViewsArray;

@property(nonatomic,strong)NSMutableDictionary *dataDic;

@property(nonatomic,strong)NSDictionary *navAndIdMap;

@property(nonatomic,assign)int currentSelectedNavIndex;
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
    [self initDatabase];
    
    [super viewDidLoad];
    
    self.navigationScrollView.selectedDelegate = self;
    self.navAndIdMap = @{@"头条": @"28",@"要闻":@"29",@"生产经营":@"30",@"东风党建":@"31",@"和谐东风":@"32",@"东风人":@"33"};
    self.navigationsArray = [NSMutableArray arrayWithArray:@[@"头条",@"要闻",@"生产经营",@"东风党建",@"和谐东风",@"东风人"]];
    
    self.newsListTableViewsArray = [NSMutableArray array];
    self.dataDic = [NSMutableDictionary dictionary];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationScrollView initNavigations:self.navigationsArray];
    
    for (int i=0; i<self.navigationsArray.count; i++) {
        PullTableView *newsListTableView = [[PullTableView alloc] initWithFrame:CGRectMake(self.newsListContainer.frame.size.width * i, 0, self.newsListContainer.frame.size.width, self.newsListContainer.frame.size.height)];
        newsListTableView.delegate = self;
        newsListTableView.dataSource = self;
        newsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        newsListTableView.navName = [self.navigationsArray objectAtIndex:i];
        newsListTableView.navID = [[self.navAndIdMap objectForKey:newsListTableView.navName] intValue];
        
        [self.newsListContainer addSubview:newsListTableView];
        [self.newsListTableViewsArray addObject:newsListTableView];
        
    }
    
    self.newsListContainer.pagingEnabled = YES;
    self.newsListContainer.bounces = NO;
    [self.newsListContainer setContentSize:CGSizeMake(self.newsListContainer.frame.size.width * self.navigationsArray.count, self.newsListContainer.frame.size.height)];
    
    self.currentSelectedNavIndex = 0;
    [self.navigationScrollView selectNavigationAtIndex:self.currentSelectedNavIndex];

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
        
        [[(NewsFocusCell *)cell focusImageView] setImageURL:[NSURL URLWithString:newsItem.field_thumbnails]];
        [(NewsFocusCell *)cell labelTitle].text = newsItem.node_title;
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:newsCellIdentifier];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:self options:nil] lastObject];
        }
        
        [[(NewsCell *)cell newsIconImageView] setImageURL:[NSURL URLWithString:newsItem.field_thumbnails]];
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
                               
- (NSString *)stringFromDate:(NSDate *)date{
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

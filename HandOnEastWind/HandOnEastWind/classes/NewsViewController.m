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
#import "AdView.h"

@interface NewsViewController ()<UIScrollViewDelegate,NavigationScrollViewSlectedDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *navigationsArray;
@property(nonatomic,strong)NSMutableArray *newsListTableViewsArray;
@property(nonatomic,assign)int currentSelectedNavIndex;
@property (strong, nonatomic)NSString *columnName;

@property(assign,nonatomic)BOOL hasImage;
@end

@implementation NewsViewController
{
    CGPoint velocity_;
}

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
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 20.0f, 320.0f, self.view.frame.size.height - 20.0f)];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
    maskView.tag = 99990;
    [self.view addSubview:maskView];
    
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    barView.backgroundColor = [UIColor colorWithRed:170.0f / 255 green:130.0f / 255 blue:60.0f /255 alpha:1];

    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0, 100, 44)];
    noticeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    noticeLabel.textColor = [UIColor whiteColor];
    noticeLabel.text = @"更多频道";
    [barView addSubview:noticeLabel];
    
    UIView *navigationContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320.0f, 0)];
    navigationContainerView.backgroundColor = [UIColor whiteColor];
    
    CGFloat gap_x = 20.0f;
    CGFloat gap_y = 20.0f;
    CGFloat start_x = 0;
    CGFloat start_y = 0;
    
    for (int i=0; i<self.navigationsArray.count; i++) {
        UILabel *navigationItem = [[UILabel alloc] init];
        navigationItem.text = [self.navigationsArray objectAtIndex:i];
        CGSize btnSize = [[self.navigationsArray objectAtIndex:i] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]
                                                    constrainedToSize:CGSizeMake(MAXFLOAT, 20.0f)];
        
        navigationItem.frame = CGRectMake(start_x + gap_x, start_y + gap_y, btnSize.width, 20.0f);
        if (navigationItem.frame.origin.x + navigationItem.frame.size.width > 320.0f) {
            start_x = 0;
            start_y = start_y + 20.0f + gap_y;
            navigationItem.frame = CGRectMake(start_x + gap_x , start_y + gap_y, btnSize.width, 20.0f);
        }
        start_x = start_x + navigationItem.frame.size.width + gap_x;

        navigationItem.textColor = [UIColor colorWithRed:.8f green:.8f blue:.8f alpha:1];
        navigationItem.font = [UIFont boldSystemFontOfSize:18.0f];
        navigationItem.backgroundColor = [UIColor clearColor];
        navigationItem.textAlignment = NSTextAlignmentCenter;
        navigationItem.layer.borderColor = [UIColor lightGrayColor].CGColor;
        navigationItem.layer.borderWidth = .5f;
        navigationItem.layer.shadowOffset = CGSizeMake(2, 2);
        navigationItem.tag = i;
        
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoreViewNavigationTap:)];
        [navigationItem addGestureRecognizer:tap];
        navigationItem.userInteractionEnabled = YES;
        
        [navigationContainerView addSubview:navigationItem];
    }
    
    navigationContainerView.frame = CGRectMake(navigationContainerView.frame.origin.x, navigationContainerView.frame.origin.y,
                                               navigationContainerView.frame.size.width, start_y + 20.0f + gap_y + gap_y);
    
    [maskView addSubview:barView];
    [maskView addSubview:navigationContainerView];
    
}

- (void)removeMoreView
{
    for (UIView *v in [self.view subviews]) {
        if (v.tag == 99990) {
            [v removeFromSuperview];
        }
    }
}

- (void)handleMoreViewNavigationTap:(UITapGestureRecognizer *)ges
{
    [self.navigationScrollView selectNavigationAtIndex:ges.view.tag];
    //[self.navigationScrollView updateAttentionViewFrame:ges.view.tag * 320.0f];
    [self removeMoreView];
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
            
            if (i < 2) {
                [newsListTableView autoRefresh];
            }
        }

        self.newsListContainer.bounces = NO;
        self.newsListContainer.pagingEnabled = YES;
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
        for (UIView *v in [self.view subviews]) {            
            v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height + 69);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id hasImage_ = [[NSUserDefaults standardUserDefaults] valueForKey:@"HASIMAGE"];
    if (!hasImage_) {
        self.hasImage = YES;
    }
    else
    {
        self.hasImage = [hasImage_ boolValue];
    }
    
    for (UITableView *newsList in self.newsListTableViewsArray) {
        [newsList reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeMoreView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    velocity_ = velocity;
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
        else
        {
            if (velocity_.x < 0) {
                AdView *adView = [AdView sharedAdView:self.view.frame];
                [UIView animateWithDuration:.5f animations:^{
                    adView.frame = CGRectMake(0, 0, adView.frame.size.width, adView.frame.size.height);
                }];
            }
        }
    }
}

- (void)selectedNavigationItemAtIndex:(int)index_
{
    //判断是否跳跃点击
    if (abs(self.currentSelectedNavIndex - index_) > 1) {
        
        //释放前面的
        PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex];
        newsListTableView.dataArray = nil;
        [newsListTableView reloadData];
        
        if (self.currentSelectedNavIndex - 1 >= 0) {
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex - 1];
            newsListTableView.dataArray = nil;
            [newsListTableView reloadData];
        }
        if (self.currentSelectedNavIndex + 1 < self.navigationsArray.count) {
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex + 1];
            newsListTableView.dataArray = nil;
            [newsListTableView reloadData];
        }
        
        //加载当前的
        PullTableView *currentNewsListTableView = [self.newsListTableViewsArray objectAtIndex:index_];
        [currentNewsListTableView autoRefresh];
        
        if (index_ - 1 >= 0) {
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:index_ - 1];
            [newsListTableView autoRefresh];
        }
        if (index_ + 1 < self.navigationsArray.count) {
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:index_ + 1];
            [newsListTableView autoRefresh];
        }
        
        self.currentSelectedNavIndex = index_;
        [self.newsListContainer setContentOffset:CGPointMake(320.0f * index_, 0)];
        return;
    }
    
    
    
    //先判断是左滑还是右滑
    BOOL isSideLeft = NO;
    if (self.currentSelectedNavIndex > index_) {
        isSideLeft = YES;
    }
    
    self.currentSelectedNavIndex = index_;
    [self.newsListContainer setContentOffset:CGPointMake(320.0f * index_, 0)];
    
    if (isSideLeft) {
        if (self.currentSelectedNavIndex - 1 >= 0) {  //前一个加载
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex - 1];
            [newsListTableView autoRefresh];
        }
        if (self.currentSelectedNavIndex + 2 < self.navigationsArray.count) {  //释放后一个
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex + 2];
            newsListTableView.dataArray = nil;
            [newsListTableView reloadData];
        }
    }
    else
    {
        if (self.currentSelectedNavIndex + 1 < self.navigationsArray.count) {  //释放后一个
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex + 1];
            [newsListTableView autoRefresh];
        }
        if (self.currentSelectedNavIndex - 2 >= 0) {  //前一个加载
            PullTableView *newsListTableView = [self.newsListTableViewsArray objectAtIndex:self.currentSelectedNavIndex - 2];
            newsListTableView.dataArray = nil;
            [newsListTableView reloadData];
        }
    }
    
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
        
        if (self.hasImage) {
            [[(NewsFocusCell *)cell focusImageView] setImageWithURL:[NSURL URLWithString:newsItem.field_thumbnails] placeholderImage:[UIImage imageNamed:@"image_default.png"]];
        }
        else
        {
            [[(NewsFocusCell *)cell focusImageView] setImage:[UIImage imageNamed:@"image_default.png"]];
        }
        
        [(NewsFocusCell *)cell labelTitle].text = newsItem.node_title;
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:newsCellIdentifier];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:self options:nil] lastObject];
        }
        
        if (self.hasImage) {
            [[(NewsCell *)cell newsIconImageView] setImageWithURL:[NSURL URLWithString:newsItem.field_thumbnails] placeholderImage:[UIImage imageNamed:@"image_default.png"]];
        }
        else
        {
            [[(NewsCell *)cell newsIconImageView] setImage:[UIImage imageNamed:@"image_default.png"]];
        }
        
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

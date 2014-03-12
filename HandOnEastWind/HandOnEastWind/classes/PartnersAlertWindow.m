//
//  PartnersAlertWindow.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-11.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "PartnersAlertWindow.h"
#import "PartnersCell.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+WebCache.h"

#import "MJRefresh.h"

@interface PartnersAlertWindow()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>
@property(nonatomic,strong)AFHTTPRequestOperation *request;
@property(nonatomic,strong)UITableView *partnersTableView;
@property(nonatomic,strong)NSMutableArray *partnersDataArray;

@property(nonatomic,strong)MJRefreshHeaderView *refreshHeaderView;
@property(nonatomic,strong)MJRefreshFooterView *refreshFooterView;

@property(nonatomic,assign)int currentPage;
@end

@implementation PartnersAlertWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        // Initialization code
        CGFloat gap = 20.0f;
        self.partnersTableView = [[UITableView alloc] initWithFrame:CGRectMake(gap, gap, self.frame.size.width - gap * 2, self.frame.size.height - gap * 2) style:UITableViewStylePlain];
        self.partnersTableView.delegate = self;
        self.partnersTableView.dataSource = self;
        self.partnersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.partnersTableView.layer.borderWidth = 2.0f;
        self.partnersTableView.layer.borderColor = [UIColor colorWithRed:170.0f / 255.0f green:130.0f / 255.0f blue:60.0f / 255.0f alpha:1].CGColor;
        [self addSubview:self.partnersTableView];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(320.0 - gap - 33 - 2, gap + 2, 33, 33);
        [closeBtn addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:closeBtn aboveSubview:self.partnersTableView];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.partnersDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *partnersCellIdentifier = @"PartnersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:partnersCellIdentifier];
    if(!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PartnersCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary *item = [self.partnersDataArray objectAtIndex:indexPath.row];
    
    [[(PartnersCell *)cell partnersIconImageView] setImageWithURL:[NSURL URLWithString:[item objectForKey:@"field_thumbnails"]]];
    [(PartnersCell *)cell partnersTitleLabel].text = [item objectForKey:@"node_title"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#define PARTNERS_REQUEST_URL [BASE_URL stringByAppendingString:@"mobile/partners?page=%d"]
- (void)show
{
    __weak PartnersAlertWindow *safe_self = self;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = self;
    
    self.hidden = NO;
    [self makeKeyAndVisible];
    
    self.refreshHeaderView = [MJRefreshHeaderView header];
    self.refreshHeaderView.delegate = self;
    self.refreshHeaderView.scrollView = self.partnersTableView;
    self.refreshHeaderView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [safe_self refreshData];
    };
    [self.refreshHeaderView beginRefreshing];
    
    self.refreshFooterView = [MJRefreshFooterView footer];
    self.refreshFooterView.delegate = self;
    self.refreshFooterView.scrollView = self.partnersTableView;
    self.refreshFooterView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        [safe_self loadMoreData];
    };
}

- (void)hide:(id)sender
{
    self.request = nil;
    self.hidden = YES;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = nil;
}

- (void)refreshData
{
    __weak PartnersAlertWindow *safe_self = self;
    
    NSString *urlString = [NSString stringWithFormat:PARTNERS_REQUEST_URL,0];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [self.request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
        id rs = [NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil];
        safe_self.partnersDataArray = [NSMutableArray arrayWithArray:rs];
        safe_self.currentPage = 1;
        [safe_self.partnersTableView reloadData];
        [safe_self.refreshHeaderView endRefreshing];
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        [safe_self.refreshHeaderView endRefreshing];
    }];
    
    [self.request start];
}

- (void)loadMoreData
{
    __weak PartnersAlertWindow *safe_self = self;

    NSString *urlString = [NSString stringWithFormat:PARTNERS_REQUEST_URL,safe_self.currentPage];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [self.request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
        id rs = [NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil];
        [safe_self.partnersDataArray addObjectsFromArray:rs];
        [safe_self.partnersTableView reloadData];
        [safe_self.refreshFooterView endRefreshing];
        safe_self.currentPage ++;
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        [safe_self.refreshFooterView endRefreshing];
    }];
    
    [self.request start];
}

- (void)dealloc
{
    self.request = nil;
    /*
    self.partnersTableView = nil;
    self.partnersDataArray = nil;
    self.refreshHeaderView = nil;
    self.refreshFooterView = nil;
     */
    
}

@end

//
//  PullTableView.m
//  TableViewPull
//
//  Created by Emre Berge Ergenekon on 2011-07-30.
//  Copyright 2011 Emre Berge Ergenekon. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullTableView.h"

#import "AFNetworking.h"
#import "FMDatabase.h"
#import "NewsModel.h"

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define REQUEST_URL @"http://zhangshangdongfeng.demo.evebit.com/mobile/news/?field_channel_tid=%d&page=%d"
#define CHANNEL_CACHE_MAX [NSNumber numberWithInt:200]

@interface PullTableView (Private) <UIScrollViewDelegate,PullTableViewDelegate>
- (void) config;
- (void) configDisplayProperties;
@end

@implementation PullTableView

# pragma mark - Initialization / Deallocation

@synthesize pullDelegate;

- (void)autoRefresh
{
    NSTimeInterval updateTime = -1;
    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
    if ([db open])
    {
        [db beginTransaction];
        
        NSString *sqlString = @"SELECT update_time FROM update_log WHERE channel_id = ?";
        FMResultSet *rs = [db executeQuery:sqlString,[NSNumber numberWithInt:self.navID]];
        while ([rs next]) {
            updateTime = [rs doubleForColumn:@"update_time"];
        }
        [db close];
    }

    if (updateTime > 0) {
        NSDate *now = [NSDate date];
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:updateTime];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *compsNow  = [calendar components:unitFlags fromDate:now];
        int yearNow = [compsNow year];
        int monthNow = [compsNow month];
        int dayNow = [compsNow day];
        
        NSDateComponents *compsUpdate = [calendar components:unitFlags fromDate:updateDate];
        int yearUpdate = [compsUpdate year];
        int monthUpdate = [compsUpdate month];
        int dayUpdate = [compsUpdate day];

        if (yearNow > yearUpdate) {
            [self setContentOffset:CGPointMake(0, -70) animated:NO];
            [refreshView egoRefreshScrollViewDidEndDragging:self];
        }
        else if(yearNow == yearUpdate)
        {
            if (monthNow > monthUpdate) {
                [self setContentOffset:CGPointMake(0, -70) animated:NO];
                [refreshView egoRefreshScrollViewDidEndDragging:self];
            }
            else if(monthNow == monthUpdate)
            {
                if (dayNow > dayUpdate) {
                    [self setContentOffset:CGPointMake(0, -70) animated:NO];
                    [refreshView egoRefreshScrollViewDidEndDragging:self];
                }
                else
                {
                    [self initDataFromCache];
                }

            }
            else
            {
                [self initDataFromCache];
            }

        }
        else
        {
            [self initDataFromCache];
        }
    }
    else
    {
        [self setContentOffset:CGPointMake(0, -70) animated:NO];
        [refreshView egoRefreshScrollViewDidEndDragging:self];
    }
}

- (void)initDataFromCache
{
    self.dataArray = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
    if ([db open])
    {
        [db beginTransaction];
        NSString *sqlString = @"SELECT * FROM news WHERE field_channel = ? ORDER BY node_created DESC ";// limit 15";
        FMResultSet *rs = [db executeQuery:sqlString,self.navName];
        while ([rs next]) {
            NewsModel *newsItem = [[NewsModel alloc] initFMResultSet:rs];
            [self.dataArray addObject:newsItem];
        }
        [db commit];
        [db close];
    }
    
    [self reloadData];
}

#pragma mark - Refresh and load more methods
- (void)refreshTable
{
    /*
     Code to actually refresh goes here.  刷新代码放在这
     */
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    
    NSString *urlString = [NSString stringWithFormat:REQUEST_URL,self.navID,0];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [self.request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
        
        self.currentPage = 1;
        [self.dataArray removeAllObjects];
        
        id rs = [NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil];
        
        FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
        if ([db open])
        {
            [db beginTransaction];
            for (int i=0; i<[rs count]; i++) {
                NewsModel *newsItem = [[NewsModel alloc] initWithDictionary:[rs objectAtIndex:i]];
                
                //删除重复的纪录，插入最新的。根据nid(文章id)区分
                NSString *sqlString = @"DELETE FROM news WHERE nid = ?";
                [db executeUpdate:sqlString,newsItem.nid];
                //插入数据
                sqlString = @"INSERT INTO news (nid,node_created,node_title,field_thumbnails,field_channel,field_newsfrom,field_summary,body_1,body_2) VALUES (?,?,?,?,?,?,?,?,?)";
                [db executeUpdate:sqlString,newsItem.nid,newsItem.node_created,newsItem.node_title,newsItem.field_thumbnails,self.navName,newsItem.field_newsfrom,newsItem.field_summary,newsItem.body_1,newsItem.body_2];
                
                //更新数据的时间戳
                sqlString = @"DELETE FROM update_log WHERE channel_id = ?";
                [db executeUpdate:sqlString,[NSNumber numberWithInt:self.navID]];
                
                sqlString = @"INSERT INTO update_log (channel_id,channel_name,update_time) VALUES (?,?,?)";
                [db executeUpdate:sqlString,[NSNumber numberWithInt:self.navID],self.navName,[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
            }
           
            /*
            //查看本频道的数据总数，超过总数的删除
            NSString *sqlString = @"DELETE FROM news WHERE id NOT IN (SELECT id FROM news WHERE field_channel = ? ORDER BY node_created DESC  limit ?) AND field_channel = ? ";
            [db executeUpdate:sqlString,self.navName,CHANNEL_CACHE_MAX,self.navName];
            
             */
            
            [db commit];
            [db close];
        }
        
        for (int i=0; i<[rs count]; i++) {
            NewsModel *newsItem = [[NewsModel alloc] initWithDictionary:[rs objectAtIndex:i]];
            [self.dataArray addObject:newsItem];
        }
        
        [self reloadData];
        self.pullLastRefreshDate = [NSDate date];
        self.pullTableIsRefreshing = NO;
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        
    }];
    
    [self.request start];
    
}

- (void)loadMoreDataToTable
{
    /*
     Code to actually load more data goes here.  加载更多实现代码放在在这
     */
    
    NSString *urlString = [NSString stringWithFormat:REQUEST_URL,self.navID,self.currentPage];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [self.request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
        
        self.currentPage++;
        
        id rs = [NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil];
        
        FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
        if ([db open])
        {
            [db beginTransaction];
            for (int i=0; i<[rs count]; i++) {
                NewsModel *newsItem = [[NewsModel alloc] initWithDictionary:[rs objectAtIndex:i]];
                
                //删除重复的纪录，插入最新的。根据nid(文章id)区分
                NSString *sqlString = @"DELETE FROM news WHERE id in ( SELECT id FROM news WHERE nid = ?)";
                [db executeUpdate:sqlString,newsItem.nid];
                
                //插入数据
                sqlString = @"INSERT INTO news (nid,node_created,node_title,field_thumbnails,field_channel,field_newsfrom,field_summary,body_1,body_2) VALUES (?,?,?,?,?,?,?,?,?)";
                [db executeUpdate:sqlString,newsItem.nid,newsItem.node_created,newsItem.node_title,newsItem.field_thumbnails,newsItem.field_channel,newsItem.field_newsfrom,newsItem.field_summary,newsItem.body_1,newsItem.body_2];
                
            }
            
            /*
            //查看本频道的数据总数，超过总数的删除
            NSString *sqlString = @"DELETE FROM news WHERE id NOT IN ( SELECT id FROM news WHERE field_channel = ? ORDER BY node_created DESC  limit ?)";
            [db executeUpdate:sqlString,self.navName,CHANNEL_CACHE_MAX];
            */
            
            [db commit];
            [db close];
        }
        
        for (int i=0; i<[rs count]; i++) {
            NewsModel *newsItem = [[NewsModel alloc] initWithDictionary:[rs objectAtIndex:i]];
            [self.dataArray addObject:newsItem];
        }
        
        [self reloadData];
        self.pullTableIsLoadingMore = NO;
        
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        
    }];
    
    [self.request start];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:.5f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:.5f];
}

////////////////////////////////////////////////////////////////////////////////////////////////////


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self config];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self config];
}


- (void)dealloc {
    [pullArrowImage release];
    [pullBackgroundColor release];
    [pullTextColor release];
    [pullLastRefreshDate release];
    
    [refreshView release];
    [loadMoreView release];
    [delegateInterceptor release];
    delegateInterceptor = nil;
    [super dealloc];
}

# pragma mark - Custom view configuration

- (void)config
{
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    /* Status Properties */
    pullTableIsRefreshing = NO;
    pullTableIsLoadingMore = NO;
    
    /* Refresh View */
    refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    refreshView.delegate = self;
    [self addSubview:refreshView];
    
    /* Load more view init */
    loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    [self addSubview:loadMoreView];
    
    self.pullDelegate = self;
}


# pragma mark - View changes

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    
    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
    
    
    
    
}

#pragma mark - Preserving the original behaviour

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)reloadData
{
    [super reloadData];
    // Give the footers a chance to fix it self.
    [loadMoreView egoRefreshScrollViewDidScroll:self];
}

#pragma mark - Status Propreties

@synthesize pullTableIsRefreshing;
@synthesize pullTableIsLoadingMore;

- (void)setPullTableIsRefreshing:(BOOL)isRefreshing
{
    if(!pullTableIsRefreshing && isRefreshing) {
        // If not allready refreshing start refreshing
        [refreshView startAnimatingWithScrollView:self];
        pullTableIsRefreshing = YES;
    } else if(pullTableIsRefreshing && !isRefreshing) {
        [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsRefreshing = NO;
    }
}

- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!pullTableIsLoadingMore && isLoadingMore) {
        // If not allready loading more start refreshing
        [loadMoreView startAnimatingWithScrollView:self];
        pullTableIsLoadingMore = YES;
    } else if(pullTableIsLoadingMore && !isLoadingMore) {
        [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsLoadingMore = NO;
    }
}

#pragma mark - Display properties

@synthesize pullArrowImage;
@synthesize pullBackgroundColor;
@synthesize pullTextColor;
@synthesize pullLastRefreshDate;

- (void)configDisplayProperties
{
    [refreshView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
}

- (void)setPullArrowImage:(UIImage *)aPullArrowImage
{
    if(aPullArrowImage != pullArrowImage) {
        [pullArrowImage release];
        pullArrowImage = [aPullArrowImage retain];
        [self configDisplayProperties];
    }
}

- (void)setPullBackgroundColor:(UIColor *)aColor
{
    if(aColor != pullBackgroundColor) {
        [pullBackgroundColor release];
        pullBackgroundColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullTextColor:(UIColor *)aColor
{
    if(aColor != pullTextColor) {
        [pullTextColor release];
        pullTextColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullLastRefreshDate:(NSDate *)aDate
{
    if(aDate != pullLastRefreshDate) {
        [pullLastRefreshDate release];
        pullLastRefreshDate = [aDate retain];
        [refreshView refreshLastUpdatedDate];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [refreshView egoRefreshScrollViewDidScroll:scrollView];
    [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    [refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [refreshView egoRefreshScrollViewWillBeginDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}



#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    pullTableIsRefreshing = YES;
    [pullDelegate pullTableViewDidTriggerRefresh:self];    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return self.pullLastRefreshDate;
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    pullTableIsLoadingMore = YES;
    [pullDelegate pullTableViewDidTriggerLoadMore:self];
}


@end

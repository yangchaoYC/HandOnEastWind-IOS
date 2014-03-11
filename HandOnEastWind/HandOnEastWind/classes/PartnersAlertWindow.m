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

@interface PartnersAlertWindow()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)AFHTTPRequestOperation *request;
@property(nonatomic,strong)UITableView *partnersTableView;
@property(nonatomic,strong)NSMutableArray *partnersDataArray;
@property(nonatomic,strong)UIActivityIndicatorView *loadingTagView;
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
        
        self.loadingTagView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        self.loadingTagView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.loadingTagView.hidden = YES;
        [self insertSubview:self.loadingTagView aboveSubview:self.partnersTableView];
        self.loadingTagView.center = self.partnersTableView.center;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        closeBtn.frame = CGRectMake(320.0 - gap - 22 - 2, gap + 2, 22, 22);
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

#define PARTNERS_REQUEST_URL @"http://zhangshangdongfeng.demo.evebit.com/mobile/partners"
- (void)show
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = self;
    
    self.hidden = NO;
    [self makeKeyAndVisible];
    
    self.partnersDataArray = [NSMutableArray array];
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:PARTNERS_REQUEST_URL]];
    self.request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [self.request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id successObject){
        //{"nid":"1285","node_title":"\u6728\u5170\u5c71\u666f\u533a","node_created":"1394444629","field_thumbnails":"http://zhangshangdongfeng.demo.evebit.com/sites/default/files/qq20140310-12x.png"}
        
        id rs = [NSJSONSerialization JSONObjectWithData:successObject options:NSJSONReadingAllowFragments error:nil];
        self.partnersDataArray = rs;
        [self.partnersTableView reloadData];
        self.loadingTagView.hidden = YES;
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        self.loadingTagView.hidden = YES;
    }];
    
    self.loadingTagView.hidden = NO;
    [self.loadingTagView startAnimating];
    [self.request start];
}

- (void)hide:(id)sender
{
    self.request = nil;
    self.hidden = YES;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.alertViewCache = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

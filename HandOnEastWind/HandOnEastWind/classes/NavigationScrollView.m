//
//  NavigationScrollView.m
//  Test2
//
//  Created by jijeMac2 on 14-2-27.
//  Copyright (c) 2014年 jijesoft. All rights reserved.
//

#import "NavigationScrollView.h"
#define navigationGap 10.0f

@interface NavigationScrollView()
@property(strong,nonatomic)NSMutableArray *navigationsArray;
@property(strong,nonatomic)UIView *attentionView;
@property(assign,nonatomic)int currentSelectedIndex;
@end

@implementation NavigationScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
    self.currentSelectedIndex = 0;
}

- (void)initNavigations:(NSArray *)navigations_
{    
    self.attentionView = [[UIView alloc] initWithFrame:CGRectZero];
    self.attentionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.attentionView];
    
    self.navigationsArray = [NSMutableArray array];
    
    CGFloat start_x = navigationGap;
    
    for (int i=0; i<navigations_.count; i++) {
        UILabel *navigationItem = [[UILabel alloc] init];
        navigationItem.text = [navigations_ objectAtIndex:i];
        CGSize btnSize = [[navigations_ objectAtIndex:i] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]
                                                      constrainedToSize:CGSizeMake(MAXFLOAT, self.bounds.size.height)];
        
        navigationItem.frame = CGRectMake(start_x, 0, btnSize.width, self.bounds.size.height - 5.0f);
        navigationItem.textColor = [UIColor colorWithRed:.8f green:.8f blue:.8f alpha:1];
        navigationItem.font = [UIFont boldSystemFontOfSize:18.0f];
        navigationItem.backgroundColor = [UIColor clearColor];
        navigationItem.textAlignment = NSTextAlignmentCenter;
        navigationItem.tag = i;
 
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [navigationItem addGestureRecognizer:tap];
        navigationItem.userInteractionEnabled = YES;
                
        [self addSubview:navigationItem];
        
        start_x += navigationItem.bounds.size.width + navigationGap;
        
        [self.navigationsArray addObject:navigationItem];
    }
    
    self.contentSize = CGSizeMake(start_x - navigationGap, self.bounds.size.height);
    
    //栏目过少，无法占满时，适配
    if (self.contentSize.width < self.frame.size.width - navigationGap) {
        CGFloat min_width = (self.frame.size.width - navigationGap - self.contentSize.width) / navigations_.count;
        for (int i=0; i<self.navigationsArray.count; i++) {
            UILabel *item = [self.navigationsArray objectAtIndex:i];
            item.frame = CGRectMake(min_width * i + item.frame.origin.x, item.frame.origin.y, min_width + item.frame.size.width, item.frame.size.height);
        }
        
        self.contentSize = CGSizeMake(self.frame.size.width, self.contentSize.height);
    }
    
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)handleTap:(UIGestureRecognizer *)ges_
{
    [self selectNavigationAtIndex:[ges_.view tag]];
}

- (void)selectNavigationAtIndex:(int)index_
{
    if (self.currentSelectedIndex > -1 && self.currentSelectedIndex < self.navigationsArray.count) {
        UILabel *item = [self.navigationsArray objectAtIndex:self.currentSelectedIndex];
        [item setTextColor:[UIColor colorWithRed:.8f green:.8f blue:.8f alpha:1]];
    }
    
    UILabel *navigationItem = [self.navigationsArray objectAtIndex:index_];
    
    [(UILabel *)navigationItem setTextColor:[UIColor whiteColor]];
    
    CGRect frame = CGRectMake(navigationItem.frame.origin.x, navigationItem.frame.size.height, navigationItem.frame.size.width, 3.0f);
    
    self.attentionView.frame = frame;
    
    //计算当前选中的栏目，保证其显示
    if (self.contentOffset.x > navigationItem.frame.origin.x - navigationGap) {
        [self setContentOffset:CGPointMake(navigationItem.frame.origin.x - navigationGap, 0) animated:YES];
    }
    else
    {
        if(self.contentOffset.x + self.bounds.size.width <  navigationItem.frame.origin.x + navigationItem.bounds.size.width)
        {
            [self setContentOffset:CGPointMake(navigationItem.frame.origin.x + navigationItem.bounds.size.width - self.bounds.size.width, 0)
                          animated:YES];
        }
    }
    
    self.currentSelectedIndex = index_;
    [self.selectedDelegate selectedNavigationItemAtIndex:self.currentSelectedIndex];
}

- (void)updateAttentionViewFrame:(CGFloat)contentOffsetX_
{
    UIView *currentView = [self.navigationsArray objectAtIndex:self.currentSelectedIndex];
    CGRect currentViewFrame = currentView.frame;
    
    CGFloat x_current = self.currentSelectedIndex * 320.0f;
    if (contentOffsetX_ > x_current) {
        //右滑动
        if (self.currentSelectedIndex > self.navigationsArray.count - 1 ) return;
        
        CGRect nextViewFrame = [[self.navigationsArray objectAtIndex:self.currentSelectedIndex + 1] frame];
        CGFloat lit = (contentOffsetX_ - x_current) / 320.0f;
        CGRect frame = CGRectMake(currentViewFrame.origin.x + lit * (currentViewFrame.size.width + navigationGap),
                                  self.attentionView.frame.origin.y,
                                  lit * nextViewFrame.size.width + currentViewFrame.size.width - lit*currentViewFrame.size.width,
                                  self.attentionView.frame.size.height);
        self.attentionView.frame = frame;
    }
    else
    {
        //左滑动
        if (self.currentSelectedIndex < 1 ) return;
        
        CGRect nextViewFrame = [[self.navigationsArray objectAtIndex:self.currentSelectedIndex - 1] frame];
        CGFloat lit = (x_current - contentOffsetX_) / 320.0f;
        CGRect frame = CGRectMake(currentViewFrame.origin.x - lit * (nextViewFrame.size.width + navigationGap),
                                  self.attentionView.frame.origin.y,
                                  currentViewFrame.size.width + lit * nextViewFrame.size.width - lit*currentViewFrame.size.width,
                                  self.attentionView.frame.size.height);
        self.attentionView.frame = frame;
    }
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

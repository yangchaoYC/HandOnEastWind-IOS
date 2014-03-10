//
//  AdView.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-3-8.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *adImageView;
+ (AdView *)sharedAdView;
- (void)setADViewImage;
@end

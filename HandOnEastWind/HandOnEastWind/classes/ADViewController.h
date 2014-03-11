//
//  ADViewController.h
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-11.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *adImageView;

- (void)updateAD;
@end

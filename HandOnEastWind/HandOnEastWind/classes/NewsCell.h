//
//  NewsCell.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-3-1.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface NewsCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet EGOImageView *newsIconImageView;
    @property (weak, nonatomic) IBOutlet UILabel *labelTitle;
    @property (weak, nonatomic) IBOutlet UILabel *labelContent;
    @property (weak, nonatomic) IBOutlet UILabel *labelDate;
    @property (weak, nonatomic) IBOutlet UILabel *labelSource;

@end

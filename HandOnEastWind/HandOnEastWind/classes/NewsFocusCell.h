//
//  NewsFocusCell.h
//  HandOnEastWind
//
//  Created by 李迪 on 14-3-1.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface NewsFocusCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet EGOImageView *focusImageView;
    @property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@end

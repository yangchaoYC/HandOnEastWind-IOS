//
//  NavigationCell.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-10.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NavigationCell.h"

@implementation NavigationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  NewsCell.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-3-1.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell
    
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
    
- (void)awakeFromNib
{
    self.newsIconImageView.layer.masksToBounds = YES;
    self.newsIconImageView.layer.cornerRadius = 5.0f;
}
    
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
        
    // Configure the view for the selected state
}

@end

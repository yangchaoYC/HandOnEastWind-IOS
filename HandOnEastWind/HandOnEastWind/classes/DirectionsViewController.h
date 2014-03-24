//
//  DirectionsViewController.h
//  HandOnEastWind
//
//  Created by 杨超 on 14-3-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectionsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *label_Title;
@property (weak, nonatomic) IBOutlet UITextView *textView_Content;
@property(nonatomic,strong) NSString *key;
@end

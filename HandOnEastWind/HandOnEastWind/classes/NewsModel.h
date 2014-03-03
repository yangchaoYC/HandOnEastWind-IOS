//
//  NewsModel.h
//  Test
//
//  Created by jijeMac2 on 14-2-26.
//  Copyright (c) 2014年 jijesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMResultSet;

@interface NewsModel : NSObject
@property(nonatomic,strong)NSNumber *nid;
@property(nonatomic,strong)NSNumber *node_created;
@property(nonatomic,strong)NSString *node_title;
@property(nonatomic,strong)NSString *field_thumbnails;

@property(nonatomic,strong)NSString *field_channel;
@property(nonatomic,strong)NSString *field_newsfrom;
@property(nonatomic,strong)NSString *field_summary;
@property(nonatomic,strong)NSString *body_1;
@property(nonatomic,strong)NSString *body_2;

- (id)initWithDictionary:(NSDictionary *)news_;
- (id)initFMResultSet:(FMResultSet *)rs_;
@end

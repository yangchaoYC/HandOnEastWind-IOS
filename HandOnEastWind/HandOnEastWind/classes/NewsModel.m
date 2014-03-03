//
//  NewsModel.m
//  Test
//
//  Created by jijeMac2 on 14-2-26.
//  Copyright (c) 2014年 jijesoft. All rights reserved.
//

#import "NewsModel.h"
#import "FMResultSet.h"

@implementation NewsModel

- (id)initWithDictionary:(NSDictionary *)news_
{
    if (self = [super init]) {
        self.nid = [NSNumber numberWithInteger:[[news_ objectForKey:@"nid"] integerValue]];
        self.node_created = [NSNumber numberWithDouble:[[news_ objectForKey:@"node_created"] doubleValue]];
        self.node_title = [news_ objectForKey:@"node_title"];
        self.field_thumbnails = [news_ objectForKey:@"field_thumbnails"];
        self.field_channel = [news_ objectForKey:@"field_channel"];
        self.field_newsfrom = [news_ objectForKey:@"field_newsfrom"];
        self.field_summary = [news_ objectForKey:@"field_summary"];
        self.body_1 = [news_ objectForKey:@"body_1"];
        self.body_2 = [news_ objectForKey:@"body_2"];
    }
    return self;
}

- (id)initFMResultSet:(FMResultSet *)rs_
{
    if (self = [super init]) {
      self.nid = [NSNumber numberWithInt:[rs_ intForColumn:@"nid"] ];
      self.node_created = [NSNumber numberWithDouble:[rs_ doubleForColumn:@"node_created"]];
      self.node_title = [rs_ stringForColumn:@"node_title"];
      self.field_thumbnails = [rs_ stringForColumn:@"field_thumbnails"];
      self.field_channel = [rs_ stringForColumn:@"field_channel"];
      self.field_newsfrom = [rs_ stringForColumn:@"field_newsfrom"];
      self.field_summary = [rs_ stringForColumn:@"field_summary"];
      self.body_1 = [rs_ stringForColumn:@"body_1"];
      self.body_2 = [rs_ stringForColumn:@"body_2"];
    }
    return self;
}
@end

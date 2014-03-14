//
//  ADDownLoadManager.h
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-14.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADDownLoadManager : NSObject

+ (ADDownLoadManager *)sharedManager;
+ (NSString *)md5HexDigest:(NSString*)input;

- (void)downLoadAD:(NSDictionary *)info adKey:(NSString *)key;
@end

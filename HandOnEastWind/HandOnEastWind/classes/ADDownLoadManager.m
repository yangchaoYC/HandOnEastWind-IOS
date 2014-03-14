//
//  ADDownLoadManager.m
//  HandOnEastWind
//
//  Created by jijeMac2 on 14-3-14.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "ADDownLoadManager.h"
#import "AFHTTPRequestOperation.h"
#import "FMDatabase.h"
#import <CommonCrypto/CommonDigest.h>

@interface ADDownLoadManager()
@property(strong,nonatomic)NSOperationQueue *adDownLoadQueue;
@property(strong,nonatomic)NSOperationQueue *adImageLoadQueue;
@end

@implementation ADDownLoadManager

+ (ADDownLoadManager *)sharedManager
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self=[super init]) {
        self.adDownLoadQueue = [[NSOperationQueue alloc] init];
        self.adImageLoadQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#define ITCACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define AD_CACHE_PATH [ITCACHE_PATH stringByAppendingPathComponent:@"AD_CACHE"]
#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define AD_BASE_URL [BASE_URL stringByAppendingString:@"mobile/adstart?nid=%d"]

- (void)downLoadAD:(NSDictionary *)info adKey:(NSString *)key
{
    //更新广告
    if(![[NSFileManager defaultManager] fileExistsAtPath:AD_CACHE_PATH])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:AD_CACHE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    NSString *urlString = [NSString stringWithFormat:AD_BASE_URL,[[info objectForKey:@"nid"] intValue]];
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *loadADInfoOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    [loadADInfoOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        id rs = [[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil] objectAtIndex:0];
        NSString *serverVersion = [rs objectForKey:@"node_changed"];
        if ([serverVersion doubleValue] != [[info objectForKey:@"node_changed"] doubleValue]) {
            NSString *downLoadImagePath = [AD_CACHE_PATH stringByAppendingPathComponent:[self.class md5HexDigest:[rs objectForKey:@"field_thumbnails"]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[rs objectForKey:@"field_thumbnails"]]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downLoadImagePath append:NO];
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                //下载进度
            }];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
                NSString *sqlStr = @"UPDATE ad_cache SET node_changed = ? ,field_thumbnails = ? WHERE node_title = ?";
                if ([db open])
                {
                    
                    [db executeUpdate:sqlStr,[NSNumber numberWithDouble:[[rs objectForKey:@"node_changed"] doubleValue]],[rs objectForKey:@"field_thumbnails"],key];
                }
                [db close];
                
                //下载完成干什么
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //下载失败干什么
            }];
            
            [self.adImageLoadQueue addOperation:operation];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [self.adDownLoadQueue addOperation:loadADInfoOperation];
}

+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (void)dealloc
{
    [self.adDownLoadQueue cancelAllOperations];
    [self.adImageLoadQueue cancelAllOperations];
}
@end

//
//  WDDiskCache.m
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import "WDDiskCache.h"
#import <CommonCrypto/CommonCrypto.h>
#import "WDKVStorage.h"

@interface WDDiskCache()

@property (nonatomic, strong) WDKVStorage *kv;
@property (nonatomic, strong) dispatch_queue_t asyncQueue;
@property (nonatomic, strong) dispatch_semaphore_t lockSemaphore;

@end

@implementation WDDiskCache

static NSString *WDNSStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)fileNameWithKey:(NSString *)key
{
    return WDNSStringMD5(key);
}

- (instancetype)initWithPath:(NSString *)path
{
    NSAssert(path.length, @"路径不能为空");
    if(self = [super init]) {
        _path = [path copy];
        NSLog(@"%@",path);
        _kv = [[WDKVStorage alloc] initWithPath:path];
        _countLimit = NSUIntegerMax;
        _sizeLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        _autoTrimInterval = 60;
        _asyncQueue = dispatch_queue_create("com.wd.diskCache", DISPATCH_QUEUE_CONCURRENT);
        _lockSemaphore = dispatch_semaphore_create(1);
        
    }
    return self;
    
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key
{
    if(!key.length) return;
    if(!object) {
        [self removeObjectForKey:key];
        return;
    }
    NSData *value = nil;
    if(self.customerArchiveBlock) {
        value = self.customerArchiveBlock(object);
    } else {
        @try {
            value = [NSKeyedArchiver archivedDataWithRootObject:object];
        } @catch (NSException *exception) {
        };
    }
    NSString *fileName = [self fileNameWithKey:key];
    [self lock];
    [self.kv saveItemWithKey:key value:value fileName:fileName];
    [self unLock];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key completion:(void (^)())completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.asyncQueue, ^{
        __strong typeof(weakSelf) self = weakSelf;
    [self setObject:object forKey:key];
        if(completion) {
            completion();
        }
    });
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    if(!key.length) return nil;
    [self lock];
    WDKVStorageItem *item = [self.kv itemWithKey:key];
    [self unLock];
    if(!item.value) return nil;
    id obj = nil;
    if(self.customrUnArchiveBlock) {
        obj  = self.customrUnArchiveBlock(item.value);
    } else {
        @try {
           obj = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
        } @catch (NSException *exception) {
        }
    }
    return obj;
}

- (void)objectForKey:(NSString *)key completion:(void (^)(NSString *, id<NSCoding>))completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.asyncQueue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        id obj = [self objectForKey:key];
        if(completion) {
            completion(key,obj);
        }
    });
}

- (void)removeObjectForKey:(NSString *)key
{
    if(!key.length) return;
    [self lock];
    [self.kv removeItemWithKey:key];
    [self unLock];
}

- (void)removeObjectForKey:(NSString *)key completion:(void (^)())completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.asyncQueue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self removeObjectForKey:key];
        if(completion) {
            completion();
        }
    });
}

- (void)removeAllObjects
{
    [self lock];
    [self.kv removeAllItems];
    [self unLock];
}

- (void)removeAllObjectsWithCompletion:(void (^)())completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.asyncQueue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self removeAllObjects];
        if(completion) {
            completion();
        }
    });
}

- (BOOL)containsObjectForKey:(NSString *)key
{
    if(!key.length) return NO;
    [self lock];
    BOOL contains = [self.kv itemExistsWithKey:key];
    [self unLock];
    return contains;
}

- (void)containsObjectForKey:(NSString *)key completion:(void (^)(NSString *, BOOL contains))completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.asyncQueue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        BOOL contains = [self containsObjectForKey:key];
        if(completion) {
            completion(key,contains);
        }
    });
}

- (void)trimToCount:(NSUInteger)count
{
    if(count >= NSUIntegerMax) return;
    [self lock];
    [self.kv removeItemsToFitCount:count];
    [self unLock];
}

- (void)trimToSize:(NSUInteger)size
{
    if(size >= NSUIntegerMax) return;
    [self lock];
    [self.kv removeItemsToFitSize:size];
    [self unLock];
}

- (void)trimToAge:(NSTimeInterval)age
{
    if(age <= 0) {
        [self lock];
        [self.kv removeAllItems];
        [self unLock];
        return;
    }
    long timestamp = time(NULL);
    if (timestamp <= age) return;
    long distAge = timestamp - age;
    if(distAge >= INT_MAX) return;
    [self lock];
    [self.kv removeItemsThatMoreThanTime:(int)distAge];
    [self unLock];
}

- (void)lock
{
    dispatch_semaphore_wait(self.lockSemaphore, DISPATCH_TIME_FOREVER);

}

- (void)unLock
{
    dispatch_semaphore_signal(self.lockSemaphore);
}

@end

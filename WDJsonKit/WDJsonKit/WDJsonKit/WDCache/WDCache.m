//
//  WDCache.m
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import "WDCache.h"

@implementation WDCache

- (instancetype)initWithName:(NSString *)name
{
    if(!name.length) return nil;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:name];
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path
{
    if(!path.length) return nil;
    if(self = [super init]) {
        _memoryCache = [[WDMemoryCache alloc] init];
        _diskCache = [[WDDiskCache alloc] initWithPath:path];
    }
    return self;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key
{
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key completion:(void (^)())completion
{
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion();
            }
        });
    }];
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if(!object) {
        object = [_diskCache objectForKey:key];
        if(object) {
            [_memoryCache setObject:object forKey:key];
        }
    }
    return object;
    
}

- (void)objectForKey:(NSString *)key completion:(void (^)(NSString *key, id<NSCoding> object))completion
{
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if(object) {
        if(completion) {
            completion(key,object);
        }
    } else {
        [_diskCache objectForKey:key completion:^(NSString *key, id<NSCoding> object) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completion) {
                    completion(key,object);
                }
                [_memoryCache setObject:object forKey:key];
            });
        }];
    }
}

- (void)removeObjectForKey:(NSString *)key
{
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key completion:(void (^)())completion
{
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion();
            }
        });
    }];
}

- (void)removeAllObjects
{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjects];
}

- (void)removeAllObjectsWithCompletion:(void (^)())completion
{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion();
            }
        });
    }];
}

- (BOOL)containsObjectForKey:(NSString *)key
{
    BOOL contains = [_memoryCache containsObjectForKey:key];
    if(contains) {
        return contains;
    }
    contains = [_diskCache containsObjectForKey:key];
    return contains;
}

- (void)containsObjectForKey:(NSString *)key completion:(void (^)(NSString *key, BOOL contains))completion
{
    BOOL contains = [_memoryCache containsObjectForKey:key];
    if(contains && completion) {
        completion(key,contains);
        return;
    }
    [_diskCache containsObjectForKey:key completion:^(NSString *key, BOOL containts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion(key,contains);
            }
        });
    }];
}

@end

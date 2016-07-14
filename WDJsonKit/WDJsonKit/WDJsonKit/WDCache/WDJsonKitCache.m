//
//  WDJsonKitCache.m
//  WDJsonKit
//
//  Created by 王迪 on 16/7/10.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDJsonKitCache.h"
#import <pthread.h>

@implementation WDJsonKitCache
{
    pthread_mutex_t _lock;
    pthread_mutex_t _sqlLock;
    pthread_mutex_t _encodingLock;
    NSMutableDictionary *_classCache;
    NSMutableDictionary *_sqlClassCache;
    NSMutableDictionary *_encodingClassCache;
    NSMutableArray *_tableNameArray;
    
}

static id _instance;

+ (instancetype)sharedCache
{
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init
{
    if(self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        pthread_mutex_init(&_sqlLock, NULL);
        pthread_mutex_init(&_encodingLock, NULL);
        _classCache = [NSMutableDictionary dictionary];
        _sqlClassCache = [NSMutableDictionary dictionary];
        _encodingClassCache = [NSMutableDictionary dictionary];
        _tableNameArray = [NSMutableArray array];
    }
    return self;
}

- (WDClassInfo *)classInfoFromCache:(Class)clazz
{
    if(!clazz) return nil;
    pthread_mutex_lock(&_lock);
    WDClassInfo *classInfo = _classCache[NSStringFromClass(clazz)];
    pthread_mutex_unlock(&_lock);
    return classInfo;
}

- (void)saveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz
{
    if(!classInfo || !clazz) return;
    pthread_mutex_lock(&_lock);
    _classCache[NSStringFromClass(clazz)] = classInfo;
    pthread_mutex_unlock(&_lock);
}

- (WDClassInfo *)sqlClassInfoFromCache:(Class)clazz
{
    if(!clazz) return nil;
    pthread_mutex_lock(&_sqlLock);
    WDClassInfo *classInfo = _sqlClassCache[NSStringFromClass(clazz)];
    pthread_mutex_unlock(&_sqlLock);
    return classInfo;
}

- (void)sqlSaveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz
{
    if(!classInfo || !clazz) return;
    pthread_mutex_lock(&_sqlLock);
    _sqlClassCache[NSStringFromClass(clazz)] = classInfo;
    pthread_mutex_unlock(&_sqlLock);
}

- (WDClassInfo *)encodingClassInfoFromCache:(Class)clazz
{
    if(!clazz) return nil;
    pthread_mutex_lock(&_encodingLock);
    WDClassInfo *classInfo = _encodingClassCache[NSStringFromClass(clazz)];
    pthread_mutex_unlock(&_encodingLock);
    return classInfo;

}

- (void)encodingSaveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz
{
    if(!classInfo || !clazz) return;
    pthread_mutex_lock(&_encodingLock);
    _encodingClassCache[NSStringFromClass(clazz)] = classInfo;
    pthread_mutex_unlock(&_encodingLock);

}

- (BOOL)containsTableName:(NSString *)tableName
{
    if(!tableName) return NO;
    pthread_mutex_lock(&_sqlLock);
    BOOL contains = [_tableNameArray containsObject:tableName];
    pthread_mutex_unlock(&_sqlLock);
    return contains;
}

- (void)saveTableName:(NSString *)tableName
{
    if(!tableName) return;
    pthread_mutex_lock(&_sqlLock);
    [_tableNameArray addObject:tableName];
    pthread_mutex_unlock(&_sqlLock);

}

@end

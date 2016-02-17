//
//  WDCacheManager.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDCacheManager.h"
#import "WDClassInfo.h"
#import <libkern/OSAtomic.h>

@implementation WDCacheManager

static CFMutableDictionaryRef _classCache;
CFMutableDictionaryRef _objectCacheDict;
static OSSpinLock _lock;
static id _instance;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       _classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _objectCacheDict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _lock = OS_SPINLOCK_INIT;
    });
}

+ (WDClassInfo *)wd_classInfoFromCache:(Class)clazz;
{
    if(!clazz) return nil;
    OSSpinLockLock(&_lock);
    WDClassInfo *classInfo = CFDictionaryGetValue(_classCache,(__bridge const void *)(clazz));
    OSSpinLockUnlock(&_lock);
    return classInfo;
}

+ (void)wd_saveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz
{
    if(!classInfo || !clazz) return;
    OSSpinLockLock(&_lock);
    CFDictionarySetValue(_classCache, (__bridge const void *)(clazz), (__bridge const void *)(classInfo));
    OSSpinLockUnlock(&_lock);
}

+ (void)wd_saveQueryModelToCache:(id)model classInfo:(WDClassInfo *)classInfo
{
    if(!model) return;
    Class clazz = [model class];
    OSSpinLockLock(&_lock);
    NSMutableDictionary *classDict = CFDictionaryGetValue(_objectCacheDict,(__bridge const void *)(clazz));
    if(!classDict) {
        classDict = [NSMutableDictionary dictionary];
        CFDictionarySetValue(_objectCacheDict, (__bridge const void *)(clazz), (__bridge const void *)(classDict));
    }
    id rowIdentifyValue = [model valueForKey:classInfo.rowIdentifyPropertyName];
    if(!rowIdentifyValue) return;
    classDict[rowIdentifyValue] = model;
    OSSpinLockUnlock(&_lock);
}

+ (void)wd_saveQueryResultToCache:(NSArray *)result classInfo:(WDClassInfo *)classInfo
{
    if(!result.count) return;
    for(id obj in result) {
        [self wd_saveQueryModelToCache:obj classInfo:classInfo];
    }
}

+ (NSArray *)wd_modelWithRowIdentify:(id)rowIdentify classInfo:(WDClassInfo *)classInfo
{
    if(!rowIdentify) return nil;
    Class clazz = classInfo.clazz;
    OSSpinLockLock(&_lock);
    NSMutableDictionary *classDict = CFDictionaryGetValue(_objectCacheDict, (__bridge const void *)(clazz));
    if(!classDict) {
        classDict = [NSMutableDictionary dictionary];
        CFDictionarySetValue(_objectCacheDict, (__bridge const void *)(clazz), (__bridge const void *)(classDict));
    }
    id model = classDict[rowIdentify];
    OSSpinLockUnlock(&_lock);
    if(!model) return nil;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:model];
    return array;
}

+ (void)wd_removeModelWithRowIdentfy:(id)rowIdentify classInfo:(WDClassInfo *)classInfo
{
    if(!rowIdentify) return;
    Class clazz = classInfo.clazz;
    OSSpinLockLock(&_lock);
    NSMutableDictionary *classDict = CFDictionaryGetValue(_objectCacheDict, (__bridge const void *)(clazz));
    if(!classDict) {
        classDict = [NSMutableDictionary dictionary];
        CFDictionarySetValue(_objectCacheDict, (__bridge const void *)(clazz), (__bridge const void *)(classDict));
    }
    [classDict removeObjectForKey:rowIdentify];
    OSSpinLockUnlock(&_lock);
}

@end

//
//  WDJsonKitCache.m
//  WDJsonKit
//
//  Created by 王迪 on 16/7/10.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDJsonKitCache.h"
#import "WDJsonKitProtocol.h"
#import <objc/runtime.h>
#import "WDClassInfo.h"
#import "WDPropertyInfo.h"

@implementation WDJsonKitCache
{
    NSMutableDictionary *_classCache;
    NSMutableDictionary *_sqlClassCache;
    NSMutableDictionary *_encodingClassCache;
    NSMutableArray *_tableNameArray;
    dispatch_semaphore_t _lock;
    dispatch_semaphore_t _sqlLock;
    dispatch_semaphore_t _encodingLock;
}

static id _instance;

+ (instancetype)sharedCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init
{
    if(self = [super init]) {
        _classCache = [NSMutableDictionary dictionary];
        _sqlClassCache = [NSMutableDictionary dictionary];
        _encodingClassCache = [NSMutableDictionary dictionary];
        _tableNameArray = [NSMutableArray array];
        _lock = dispatch_semaphore_create(1);
        _sqlLock = dispatch_semaphore_create(1);
        _encodingLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (WDClassInfo *)classInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    [self lock];
    WDClassInfo *classInfo = _classCache[NSStringFromClass(clazz)];
    [self unLock];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self classInfoFromCache:superClazz];
        classInfo.name = @(class_getName(clazz));
        classInfo.clazz = clazz;
        classInfo.superClazz = superClazz;
        unsigned int outCount = 0;
        NSDictionary *mappingDict = nil;
        if([clazz respondsToSelector:@selector(wd_replaceKeysFromOriginKeys)]) {
            mappingDict = [clazz wd_replaceKeysFromOriginKeys];
        }
        NSDictionary *classInArrayDict = nil;
        if([clazz respondsToSelector:@selector(wd_classInArray)]) {
            classInArrayDict = [clazz wd_classInArray];
        }
        NSArray *propertyWhiteList = nil;
        if([clazz respondsToSelector:@selector(wd_propertyWhiteList)]) {
            propertyWhiteList = [clazz wd_propertyWhiteList];
        }
        NSArray *propertyBlackList = nil;
        if([clazz respondsToSelector:@selector(wd_propertyBlackList)]) {
            propertyBlackList = [clazz wd_propertyBlackList];
        }
        NSMutableArray *tmpPropertys = [NSMutableArray array];
        if(classInfo.superClassInfo.propertyCache) {
            [tmpPropertys addObjectsFromArray:classInfo.superClassInfo.propertyCache];
        }
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo propertyWithProperty_t:property];
            [tmpPropertys addObject:propertyInfo];
        }
        
        for(WDPropertyInfo *propertyInfo in tmpPropertys) {
            if(!propertyInfo.name.length) continue;
            if(!propertyWhiteList.count && !propertyBlackList.count) {
                [classInfo.propertyCache addObject:propertyInfo];
            } else if((propertyWhiteList.count && [propertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.propertyCache addObject:propertyInfo];
            } else if(propertyBlackList.count && ![propertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.propertyCache addObject:propertyInfo];
            }
            [propertyInfo setupkeysMappingWithMappingDict:mappingDict];
            [propertyInfo setupClassInArrayWithClassInArrayDict:classInArrayDict];
        }
        if(propertys) {
            free(propertys);
        }
        [self lock];
        _classCache[NSStringFromClass(clazz)] = classInfo;
        [self unLock];
    }
    return classInfo;
}

- (WDClassInfo *)encodingClassInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    [self encodingLock];
    WDClassInfo *classInfo = _encodingClassCache[NSStringFromClass(clazz)];
    [self encodingUnLock];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self encodingClassInfoFromCache:superClazz];
        classInfo.name = @(class_getName(clazz));
        classInfo.clazz = clazz;
        classInfo.superClazz = superClazz;
        unsigned int outCount = 0;
        NSArray *encodingPropertyWhiteList = nil;
        if([clazz respondsToSelector:@selector(wd_encodingPropertyWhiteList)]) {
            encodingPropertyWhiteList = [clazz wd_encodingPropertyWhiteList];
        }
        NSArray *encodingPropertyBlackList = nil;
        if([clazz respondsToSelector:@selector(wd_encodingPropertyBlackList)]) {
            encodingPropertyBlackList = [clazz wd_encodingPropertyBlackList];
        }
        
        NSMutableArray *tmpPropertys = [NSMutableArray array];
        if(classInfo.superClassInfo.encodingPropertyCache) {
            [tmpPropertys addObjectsFromArray:classInfo.superClassInfo.encodingPropertyCache];
        }
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo propertyWithProperty_t:property];
            [tmpPropertys addObject:propertyInfo];
        }
        for(WDPropertyInfo *propertyInfo in tmpPropertys) {
            if(!propertyInfo.name.length) continue;
            if(!encodingPropertyWhiteList.count && !encodingPropertyBlackList.count) {
                [classInfo.encodingPropertyCache addObject:propertyInfo];
            } else if((encodingPropertyWhiteList.count && [encodingPropertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.encodingPropertyCache addObject:propertyInfo];
            } else if(encodingPropertyBlackList.count && ![encodingPropertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.encodingPropertyCache addObject:propertyInfo];
            }
        }
        if(propertys) {
            free(propertys);
        }
        [self encodingLock];
        _encodingClassCache[NSStringFromClass(clazz)] = classInfo;
        [self encodingUnLock];
    }
    return classInfo;
}

- (WDClassInfo *)sqlClassInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    [self sqlLock];
    WDClassInfo *classInfo = _sqlClassCache[NSStringFromClass(clazz)];
    [self sqlUnLock];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self sqlClassInfoFromCache:superClazz];
        if(!classInfo.superClassInfo) {
            [classInfo addExtensionProperty];
        }
        classInfo.name = @(class_getName(clazz));
        classInfo.clazz = clazz;
        classInfo.superClazz = superClazz;
        NSString *tableName = nil;
        if([clazz respondsToSelector:@selector(wd_sqlTableName)]) {
            tableName = [clazz wd_sqlTableName];
        }
        classInfo.tableName = tableName ? : NSStringFromClass(classInfo.clazz);
        unsigned int outCount = 0;
        NSDictionary *sqlMappingDict = nil;
        if([clazz respondsToSelector:@selector(wd_sqlReplaceKeysFromOriginKeys)]) {
            sqlMappingDict = [clazz wd_sqlReplaceKeysFromOriginKeys];
        }
        NSDictionary *sqlClassInArrayDict = nil;
        if([clazz respondsToSelector:@selector(wd_sqlClassInArray)]) {
            sqlClassInArrayDict = [clazz wd_sqlClassInArray];
        }
        NSArray *sqlPropertyWhiteList = nil;
        if([clazz respondsToSelector:@selector(wd_sqlPropertyWhiteList)]) {
            sqlPropertyWhiteList = [clazz wd_sqlPropertyWhiteList];
        }
        NSArray *sqlPropertyBlackList = nil;
        if([clazz respondsToSelector:@selector(wd_sqlPropertyBlackList)]) {
            sqlPropertyBlackList = [clazz wd_sqlPropertyBlackList];
        }
        NSArray *sqlIgnoreBuildNewTableArray = nil;
        if([clazz respondsToSelector:@selector(wd_sqlIgnoreBuildNewTableKeys)]) {
            sqlIgnoreBuildNewTableArray = [clazz wd_sqlIgnoreBuildNewTableKeys];
        }
        if([clazz respondsToSelector:@selector(wd_sqlRowIdentifyPropertyName)]) {
            classInfo.rowIdentifyPropertyName = [clazz wd_sqlRowIdentifyPropertyName];
        }
        
        NSMutableArray *tmpPropertys = [NSMutableArray array];
        if(classInfo.superClassInfo.sqlPropertyCache) {
            [tmpPropertys addObjectsFromArray:classInfo.superClassInfo.sqlPropertyCache];
        }
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo propertyWithProperty_t:property];
            [tmpPropertys addObject:propertyInfo];
        }
        for(WDPropertyInfo *propertyInfo in tmpPropertys) {
            if(!propertyInfo.name.length) continue;
            if(!sqlPropertyWhiteList.count && !sqlPropertyBlackList.count) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            } else if((sqlPropertyWhiteList.count && [sqlPropertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            } else if(sqlPropertyBlackList.count && ![sqlPropertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            }
            [propertyInfo setupSQLClassInArrayWithSQLClassInArrayDict:sqlClassInArrayDict];
            [propertyInfo setupSQLIgnoreBuildNewTableKeyWithignoreBuildNewTableArray:sqlIgnoreBuildNewTableArray];
            [propertyInfo setupSQLKeysMappingWithSQLMappingDict:sqlMappingDict];
            if([propertyInfo.name isEqualToString:classInfo.rowIdentifyPropertyName]) {
                classInfo.rowIdentityColumnName = propertyInfo.sqlColumnName;
            }
        }
        if(propertys) {
            free(propertys);
        }
        [self sqlLock];
        _sqlClassCache[NSStringFromClass(clazz)] = classInfo;
        [self sqlUnLock];
    }

    return classInfo;
}

- (void)lock
{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unLock
{
    dispatch_semaphore_signal(_lock);
}

- (void)sqlLock
{
    dispatch_semaphore_wait(_sqlLock, DISPATCH_TIME_FOREVER);
}

- (void)sqlUnLock
{
    dispatch_semaphore_signal(_sqlLock);
}

- (void)encodingLock
{
    dispatch_semaphore_wait(_encodingLock, DISPATCH_TIME_FOREVER);
}

- (void)encodingUnLock
{
    dispatch_semaphore_signal(_encodingLock);
}


- (BOOL)containsTableName:(NSString *)tableName
{
    if(!tableName) return NO;
    [self sqlLock];
    BOOL contains = [_tableNameArray containsObject:tableName];
    [self sqlUnLock];
    return contains;
}

- (void)removeTableName:(NSString *)tableName
{
    if(!tableName) return;
    [self sqlLock];
    [_tableNameArray removeObject:tableName];
    [self sqlUnLock];
}
- (void)saveTableName:(NSString *)tableName
{
    if(!tableName) return;
    [self sqlLock];
    [_tableNameArray addObject:tableName];
    [self sqlUnLock];
}

@end

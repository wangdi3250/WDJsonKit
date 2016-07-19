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
    NSRecursiveLock *_lock;
    NSRecursiveLock *_sqlLock;
    NSRecursiveLock *_encodingLock;
    NSMutableDictionary *_classCache;
    NSMutableDictionary *_sqlClassCache;
    NSMutableDictionary *_encodingClassCache;
    NSMutableArray *_tableNameArray;
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
        _lock = [[NSRecursiveLock alloc] init];
        _sqlLock = [[NSRecursiveLock alloc] init];
        _encodingLock = [[NSRecursiveLock alloc] init];
        _classCache = [NSMutableDictionary dictionary];
        _sqlClassCache = [NSMutableDictionary dictionary];
        _encodingClassCache = [NSMutableDictionary dictionary];
        _tableNameArray = [NSMutableArray array];
    }
    return self;
}

- (WDClassInfo *)classInfoFromCache:(Class)clazz
{
    [_lock lock];
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = _classCache[NSStringFromClass(clazz)];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self classInfoFromCache:superClazz];
        if(classInfo.superClassInfo.propertyCache.count) {
            [classInfo.propertyCache addObjectsFromArray:classInfo.superClassInfo.propertyCache];
        }
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
        
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo propertyWithProperty_t:property];
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
        _classCache[NSStringFromClass(clazz)] = classInfo;
    }
    [_lock unlock];
    return classInfo;
}

- (WDClassInfo *)encodingClassInfoFromCache:(Class)clazz
{
    [_encodingLock lock];
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = _encodingClassCache[NSStringFromClass(clazz)];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self encodingClassInfoFromCache:superClazz];
        if(classInfo.superClassInfo.encodingPropertyCache.count) {
            [classInfo.encodingPropertyCache addObjectsFromArray:classInfo.superClassInfo.encodingPropertyCache];
        }
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
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo propertyWithProperty_t:property];
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
        _encodingClassCache[NSStringFromClass(clazz)] = classInfo;
    }
    [_encodingLock unlock];
    return classInfo;
}

- (WDClassInfo *)sqlClassInfoFromCache:(Class)clazz
{
    [_sqlLock lock];
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = _sqlClassCache[NSStringFromClass(clazz)];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self sqlClassInfoFromCache:superClazz];
        if(!classInfo.superClassInfo) {
            [classInfo addExtensionProperty];
        }
        if(classInfo.superClassInfo.sqlPropertyCache.count) {
            [classInfo.sqlPropertyCache addObjectsFromArray:classInfo.superClassInfo.sqlPropertyCache];
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
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo propertyWithProperty_t:property];
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
        _sqlClassCache[NSStringFromClass(clazz)] = classInfo;
    }
    [_sqlLock unlock];
    return classInfo;
}

- (BOOL)containsTableName:(NSString *)tableName
{
    if(!tableName) return NO;
    [_sqlLock lock];
    BOOL contains = [_tableNameArray containsObject:tableName];
    [_sqlLock unlock];
    return contains;
}

- (void)removeTableName:(NSString *)tableName
{
    if(!tableName) return;
    [_sqlLock lock];
    [_tableNameArray removeObject:tableName];
    [_sqlLock unlock];
}
- (void)saveTableName:(NSString *)tableName
{
    if(!tableName) return;
    [_sqlLock lock];
    [_tableNameArray addObject:tableName];
    [_sqlLock unlock];
}

@end

//
//  NSObject+WDJsonKit.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "NSObject+WDJsonKit.h"
#import <objc/runtime.h>
#import "WDJsonKitManager.h"
#import "WDClassInfo.h"

@implementation NSObject (WDJsonKit)

- (void)setWd_aID:(NSInteger)wd_aID
{
    objc_setAssociatedObject(self, @"wd_aID", @(wd_aID), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)wd_aID
{
    return [objc_getAssociatedObject(self, @"wd_aID") integerValue];
}

+ (instancetype)wd_modelWithJson:(id)json
{
    WDClassInfo *classInfo = [self wd_classInfoFromCache];
    return [classInfo modelWithJson:json];
}

+ (NSArray *)wd_modelArrayWithJsonArray:(id)json
{
    WDClassInfo *classInfo = [self wd_classInfoFromCache];
    return [classInfo modelArrayWithJsonArray:json];
}

+ (WDClassInfo *)wd_classInfoFromCache
{
    WDClassInfo *classInfo = [[WDJsonKitManager sharedManager] classInfoFromCache:[self class]];
    return classInfo;
}

+ (WDClassInfo *)wd_sqlClassInfoFromChe
{
    WDClassInfo *classInfo = [[WDJsonKitManager sharedManager] sqlClassInfoFromCache:[self class]];
    return classInfo;
}

+ (WDClassInfo *)wd_encodingClassInfoFromCache
{
    WDClassInfo *classInfo = [[WDJsonKitManager sharedManager] encodingClassInfoFromCache:[self class]];
    return classInfo;
}

- (NSDictionary *)wd_jsonWithModel
{
    WDClassInfo *classInfo = [[self class] wd_classInfoFromCache];
    classInfo.object = self;
    return [classInfo wd_jsonWithModel];
}

+ (NSArray *)wd_jsonArrayWithModelArray:(id)model
{
    WDClassInfo *classInfo = [self wd_classInfoFromCache];
    return [classInfo jsonArrayWithModelArray:model];
}

#pragma mark - 归档解档
- (void)wd_encodeWithCoder:(NSCoder *)aCoder
{
    WDClassInfo *classInfo = [[self class] wd_encodingClassInfoFromCache];
    classInfo.object = self;
    [classInfo wd_encodeWithCoder:aCoder];
}

- (void)wd_decodeWithCoder:(NSCoder *)aDecoder
{
    WDClassInfo *classInfo = [[self class] wd_encodingClassInfoFromCache];
    classInfo.object = self;
    [classInfo wd_decodeWithCoder:aDecoder];
}

#pragma mark - 数据库相关操作
- (BOOL)wd_save
{
    __block BOOL res = NO;
    [[self class] wd_saveWithModel:self async:NO resultBlock:^(BOOL success) {
        res = success;
    }];
    return res;
}

+ (void)wd_saveWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] saveWithModel:model async:async resultBlock:resultBlock];
}

+ (void)wd_saveWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] saveWithModels:models async:async resultBlock:resultBlock];
}

- (BOOL)wd_insert
{
    __block BOOL res = NO;
    [[self class] wd_insertWithModel:self async:NO resultBlock:^(BOOL success) {
        res = success;
    }];
    return res;
}

+ (void)wd_insertWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] insertWithModel:model async:async resultBlock:resultBlock];
}

+ (void)wd_insertWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] insertWithModels:models async:async resultBlock:resultBlock];
}

+ (NSArray *)wd_query
{
    __block NSArray *res = nil;
    [self wd_queryWithWhere:nil groupBy:nil orderBy:nil limit:nil async:NO resultBlock:^(NSArray *result) {
        res = result;
    }];
    return res;
}

+ (void)wd_queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock
{
    [[WDJsonKitManager sharedManager] queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit clazz:self async:async resultBlock:resultBlock];
}

+ (void)wd_queryWithParam:(NSDictionary *)param groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock
{
    [[WDJsonKitManager sharedManager] queryWithParam:param groupBy:groupBy orderBy:orderBy limit:limit clazz:self async:async resultBlock:resultBlock];
}

+ (void)wd_queryWithRowIdentify:(id)identify async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock
{
    [[WDJsonKitManager sharedManager] queryWithRowIdentify:identify clazz:self async:async resultBlock:resultBlock];
}

+ (BOOL)wd_delete
{
    __block BOOL res = NO;
    [self wd_deleteWithWhere:nil async:NO resultBlock:^(BOOL success) {
        res = success;
    }];
    return res;
}

+ (void)wd_deleteWithWhere:(NSString *)where async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] deleteWithWhere:where clazz:self async:async resultBlock:resultBlock];
}

+ (void)wd_deleteWithParam:(NSDictionary *)param async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] deleteWithParam:param clazz:self async:async resultBlock:resultBlock];
}

- (BOOL)wd_update
{
    __block BOOL res = NO;
    [[self class] wd_updateWithModel:self async:NO resultBlock:^(BOOL success) {
        res = success;
    }];
    return res;
}

+ (void)wd_updateWithModel:(NSObject *)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] updateWithModel:model clazz:self async:async resultBlock:resultBlock];
}

+ (void)wd_updateWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] updateWithModels:models clazz:self async:async resultBlock:resultBlock];
}

//+ (BOOL)wd_clearTable
//{
//    WDClassInfo *classInfo = [WDClassInfo wd_sqlClassInfoFromCache:self];
//    if(!classInfo.tableName) return NO;
//    return [classInfo wd_clearTable:classInfo.tableName];
//}

@end

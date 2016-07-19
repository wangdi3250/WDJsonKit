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

- (void)setWd_aID:(NSObject *)wd_aID
{
    objc_setAssociatedObject(self, @selector(wd_aID), wd_aID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject *)wd_aID
{
    return objc_getAssociatedObject(self, _cmd);
}

+ (instancetype)wd_modelWithJson:(id)json
{
    return [[WDJsonKitManager sharedManager] modelWithJson:json clazz:self];
}

+ (NSArray *)wd_modelArrayWithJsonArray:(id)json
{
    return [[WDJsonKitManager sharedManager] modelArrayWithJsonArray:json clazz:self];
}

+ (WDClassInfo *)wd_sqlClassInfoFromChe
{
    WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:[self class]];
    return classInfo;
}

- (NSDictionary *)wd_jsonWithModel
{
    return [[WDJsonKitManager sharedManager] jsonWithModel:self];
}

+ (NSArray *)wd_jsonArrayWithModelArray:(id)model
{
    return [[WDJsonKitManager sharedManager] jsonArrayWithModelArray:model];
}

#pragma mark - 归档解档
- (void)wd_encodeWithCoder:(NSCoder *)aCoder
{
    [[WDJsonKitManager sharedManager] encodeWithCoder:aCoder object:self];
}

- (void)wd_decodeWithCoder:(NSCoder *)aDecoder
{
    [[WDJsonKitManager sharedManager] decodeWithCoder:aDecoder object:self];
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

+ (void)wd_clearTable:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    [[WDJsonKitManager sharedManager] clearTable:self async:async resultBlock:resultBlock];
}

@end

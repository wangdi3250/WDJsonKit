//
//  NSObject+WDJsonKit.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "NSObject+WDJsonKit.h"
#import <objc/runtime.h>
#import "WDClassInfo.h"
#import "WDCacheManager.h"
#import "WDFMDB.h"

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
    return [classInfo wd_modelWithJson:json];
}

+ (NSArray *)wd_modelArrayWithJsonArray:(id)json
{
    WDClassInfo *classInfo = [self wd_classInfoFromCache];
    return [classInfo wd_modelArrayWithJsonArray:json];
}

+ (WDClassInfo *)wd_classInfoFromCache
{
    WDClassInfo *classInfo = [WDClassInfo wd_classInfoFromCache:[self class]];
    return classInfo;
}

+ (WDClassInfo *)wd_sqlClassInfoFromChe
{
    WDClassInfo *classInfo = [WDClassInfo wd_sqlClassInfoFromCache:[self class]];
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
    return [classInfo wd_jsonArrayWithModelArray:model];
}

#pragma mark - 归档解档
- (void)wd_encodeWithCoder:(NSCoder *)aCoder
{
    WDClassInfo *classInfo = [[self class] wd_classInfoFromCache];
    classInfo.object = self;
    [classInfo wd_encodeWithCoder:aCoder];
}

- (void)wd_decodeWithCoder:(NSCoder *)aDecoder
{
    WDClassInfo *classInfo = [[self class] wd_classInfoFromCache];
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
    WDClassInfo *classInfo = [[self class] wd_sqlClassInfoFromChe];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            classInfo.object = model;
            [classInfo wd_saveWithResultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        classInfo.object = model;
        [classInfo wd_saveWithResultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
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
    WDClassInfo *classInfo = [[self class] wd_sqlClassInfoFromChe];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            classInfo.object = model;
            [classInfo wd_insertWithResultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        classInfo.object = model;
        [classInfo wd_insertWithResultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
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
    WDClassInfo *classInfo = [self wd_sqlClassInfoFromChe];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [classInfo wd_queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit resultBlock:^(NSArray *result) {
                if(resultBlock) {
                    resultBlock(result);
                }
            }];
        });
    } else {
        [classInfo wd_queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit resultBlock:^(NSArray *result) {
            if(resultBlock) {
                resultBlock(result);
            }
        }];
    }
}

+ (void)wd_queryWithParam:(NSDictionary *)param groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock
{
    __block NSMutableString *where = [NSMutableString string];
    [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[NSString class]]) {
            [where appendFormat:@"%@ = '%@' AND ",key,obj];
        } else {
            [where appendFormat:@"%@ = %@ AND ",key,obj];
        }
    }];
    if(where.length) {
        NSRange range = [where rangeOfString:@"AND " options:NSBackwardsSearch];
        if(range.length) {
            [where replaceCharactersInRange:range withString:@""];
            [self wd_queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit async:async resultBlock:resultBlock];
        }
    }
}

+ (void)wd_queryWithRowIdentify:(id)identify async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock
{
    WDClassInfo *classInfo = [self wd_sqlClassInfoFromChe];
    NSArray *models = [WDCacheManager wd_modelWithRowIdentify:identify classInfo:classInfo];
    if(models.count) {
        if(resultBlock) {
            resultBlock(models);
        }
        return;
    }
    NSString *where = [NSString stringWithFormat:@"%@ = %@",classInfo.rowIdentityColumnName,identify];
    [self wd_queryWithWhere:where groupBy:nil orderBy:nil limit:nil async:async resultBlock:^(NSArray *result) {
        if(resultBlock) {
            resultBlock(result);
        }
    }];
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
     WDClassInfo *classInfo = [WDClassInfo wd_sqlClassInfoFromCache:self];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [classInfo wd_deleteWithWhere:where resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        [classInfo wd_deleteWithWhere:where resultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
}

+ (void)wd_deleteWithParam:(NSDictionary *)param async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    __block NSMutableString *where = [NSMutableString string];
    [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[NSString class]]) {
            [where appendFormat:@"%@ = '%@' AND ",key,obj];
        } else {
            [where appendFormat:@"%@ = %@ AND ",key,obj];
        }
    }];
    if(where.length) {
        NSRange range = [where rangeOfString:@"AND " options:NSBackwardsSearch];
        if(range.length) {
            [where replaceCharactersInRange:range withString:@""];
            [self wd_deleteWithWhere:where async:async resultBlock:resultBlock];
        }
    }

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
    WDClassInfo *classInfo = [WDClassInfo wd_sqlClassInfoFromCache:self];
    id rowIdentifyValue = [model valueForKey:classInfo.rowIdentifyPropertyName];
    if(!rowIdentifyValue) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [classInfo wd_updateWithModel:model resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
        
    } else {
        [classInfo wd_updateWithModel:model resultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
}

+ (BOOL)wd_clearTable
{
    WDClassInfo *classInfo = [WDClassInfo wd_sqlClassInfoFromCache:self];
    if(!classInfo.tableName) return NO;
    return [classInfo wd_clearTable:classInfo.tableName];
}

@end

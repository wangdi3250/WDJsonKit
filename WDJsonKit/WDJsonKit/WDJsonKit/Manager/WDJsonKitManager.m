//
//  WDJsonKitManager.m
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDJsonKitManager.h"
#import "WDClassInfo.h"
#import <objc/runtime.h>
#import "WDJsonKitConst.h"
#import "WDJsonKitProtocol.h"
#import "WDPropertyInfo.h"
#import "WDDBOperation.h"
#import "WDTransformOperation.h"

@implementation WDJsonKitManager
{
    dispatch_queue_t _dbOperationQueue;
}

@synthesize cache = _cache;
@synthesize dbOperation = _dbOperation;

static id _instance;

+ (instancetype)sharedManager
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
        _cache = [WDJsonKitCache sharedCache];
        _dbOperation = [WDDBOperation sharedOperation];
        _transformOperation = [WDTransformOperation sharedOperation];
        _dbOperationQueue = dispatch_queue_create("dbOperationQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)modelWithJson:(id)json clazz:(Class)clazz
{
    if(!clazz) return nil;
    if(!json) return nil;
    WDClassInfo *classInfo = [self.cache classInfoFromCache:clazz];
    return [self.transformOperation modelWithJson:json classInfo:classInfo];
}

- (NSArray *)modelArrayWithJsonArray:(id)json clazz:(Class)clazz
{
    if(!clazz) return nil;
    if(!json) return nil;
    WDClassInfo *classInfo = [self.cache classInfoFromCache:clazz];
    return [self.transformOperation modelArrayWithJsonArray:json classInfo:classInfo];
}

- (NSDictionary *)jsonWithModel:(id)model
{
    if(!model) return nil;
    WDClassInfo *classInfo = [self.cache classInfoFromCache:[model class]];
    classInfo.object = model;
    return [self.transformOperation jsonWithModel:classInfo];
}

- (NSArray *)jsonArrayWithModelArray:(id)model
{
    return [self.transformOperation jsonArrayWithModelArray:model];
}

- (void)encodeWithCoder:(NSCoder *)aCoder object:(id)object
{
    if(!object) return;
    WDClassInfo *classInfo = [self.cache encodingClassInfoFromCache:[object class]];
    classInfo.object = object;
    [self.transformOperation encodeWithCoder:aCoder classInfo:classInfo];
    
}

- (void)decodeWithCoder:(NSCoder *)aDecoder object:(id)object
{
    if(!object) return;
    WDClassInfo *classInfo = [self.cache encodingClassInfoFromCache:[object class]];
    classInfo.object = object;
    [self.transformOperation decodeWithCoder:aDecoder classInfo:classInfo];
}

- (void)saveWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
            classInfo.object = model;
            [self.dbOperation saveWithClassInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
            classInfo.object = model;
            [self.dbOperation saveWithClassInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    }
}

- (void)saveWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(![models isKindOfClass:[NSArray class]]) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            for(id model in models) {
                WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
                classInfo.object = model;
                [self.dbOperation saveWithClassInfo:classInfo resultBlock:^(BOOL success) {
                    if(success) {
                        [resultArray addObject:@(success)];
                    }
                }];
            }
            if(resultBlock) {
                if(resultArray.count == models.count) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            for(id model in models) {
                WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
                classInfo.object = model;
                [self.dbOperation saveWithClassInfo:classInfo resultBlock:^(BOOL success) {
                    if(success) {
                        [resultArray addObject:@(success)];
                    }
                }];
            }
            if(resultBlock) {
                if(resultArray.count == models.count) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
        });
    }
}

- (void)insertWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
            classInfo.object = model;
            [self.dbOperation insertWithClassInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
            classInfo.object = model;
            [self.dbOperation insertWithClassInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    }
}

- (void)insertWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(![models isKindOfClass:[NSArray class]]) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            for(id model in models) {
                WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
                classInfo.object = model;
                [self.dbOperation insertWithClassInfo:classInfo resultBlock:^(BOOL success) {
                    if(success) {
                        [resultArray addObject:@(success)];
                    }
                }];
            }
            if(resultBlock) {
                if(resultArray.count == models.count) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            for(id model in models) {
                WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
                classInfo.object = model;
                [self.dbOperation insertWithClassInfo:classInfo resultBlock:^(BOOL success) {
                    if(success) {
                        [resultArray addObject:@(success)];
                    }
                }];
            }
            if(resultBlock) {
                if(resultArray.count == models.count) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
        });
    }
}

- (void)queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *))resultBlock
{
    if(async) {
        dispatch_async(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
            [self.dbOperation queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit classInfo:classInfo resultBlock:^(NSArray *result) {
                if(resultBlock) {
                    resultBlock(result);
                }
            }];
        });
    } else {
        WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
        [self.dbOperation queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit classInfo:classInfo resultBlock:^(NSArray *result) {
            if(resultBlock) {
                resultBlock(result);
            }
        }];
    }
}

- (void)queryWithParam:(NSDictionary *)param groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *))resultBlock
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
            [self queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit clazz:clazz async:async resultBlock:resultBlock];
        }
    }
}

- (void)queryWithRowIdentify:(id)identify clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *))resultBlock
{
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
    NSString *where = [NSString stringWithFormat:@"%@ = %@",classInfo.rowIdentityColumnName,identify];
    [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil clazz:clazz async:async resultBlock:resultBlock];
}

- (void)deleteWithWhere:(NSString *)where clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
            [self.dbOperation deleteWithWhere:where classInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
        [self.dbOperation deleteWithWhere:where classInfo:classInfo resultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
}

- (void)deleteWithParam:(NSDictionary *)param clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
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
            [self deleteWithWhere:where clazz:clazz async:async resultBlock:resultBlock];
        }
    }
}

- (void)updateWithModel:(NSObject *)model clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
            [self.dbOperation updateWithModel:model classInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
            [self.dbOperation updateWithModel:model classInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    }
}

- (void)updateWithModels:(NSArray *)models clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(![models isKindOfClass:[NSArray class]]) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            for(NSObject *model in models) {
                [self updateWithModel:model clazz:clazz async:NO resultBlock:^(BOOL success) {
                    if(success) {
                        [resultArray addObject:@(success)];
                    }
                }];
            }
            if(resultBlock) {
                if(resultArray.count == models.count) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            for(NSObject *model in models) {
                WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
                [self.dbOperation updateWithModel:model classInfo:classInfo resultBlock:^(BOOL success) {
                    if(success) {
                        [resultArray addObject:@(success)];
                    }
                }];
            }
            if(resultBlock) {
                if(resultArray.count == models.count) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
        });
    }
}

- (void)clearTable:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    if(async) {
        dispatch_barrier_async(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
            [self.dbOperation clearTable:classInfo.tableName resultBlock:resultBlock];
        });
    } else {
        dispatch_barrier_sync(_dbOperationQueue, ^{
            WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
            [self.dbOperation clearTable:classInfo.tableName resultBlock:resultBlock];
        });
    }
}

@end

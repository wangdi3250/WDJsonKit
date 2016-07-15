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
#import <pthread.h>
#import "WDJsonKitConst.h"
#import "WDJsonKitProtocol.h"
#import "WDPropertyInfo.h"
#import "WDDBOperation.h"

@implementation WDJsonKitManager
{
    pthread_mutex_t _lock;
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
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (WDDBOperation *)dbOperation
{
    pthread_mutex_lock(&_lock);
    WDDBOperation *dbOperation = _dbOperation;
    pthread_mutex_unlock(&_lock);
    return dbOperation;
}

- (void)saveWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            classInfo.object = model;
            [self.dbOperation saveWithClassInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        classInfo.object = model;
        [self.dbOperation saveWithClassInfo:classInfo resultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
}

- (void)saveWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    NSMutableArray *resultArray = [NSMutableArray array];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(id model in models) {
                [self saveWithModel:model async:NO resultBlock:^(BOOL success) {
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
        for(id model in models) {
            [self saveWithModel:model async:NO resultBlock:^(BOOL success) {
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
    }
}

- (void)insertWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:[model class]];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            classInfo.object = model;
            [self.dbOperation insertWithClassInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
        classInfo.object = model;
        [self.dbOperation insertWithClassInfo:classInfo resultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
}

- (void)insertWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    NSMutableArray *resultArray = [NSMutableArray array];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(id model in models) {
                [self insertWithModel:model async:NO resultBlock:^(BOOL success) {
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
        for(id model in models) {
            [self insertWithModel:model async:NO resultBlock:^(BOOL success) {
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
    }
}

- (void)queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *))resultBlock
{
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.dbOperation queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit classInfo:classInfo resultBlock:^(NSArray *result) {
                if(resultBlock) {
                    resultBlock(result);
                }
            }];
        });
    } else {
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

- (void)deleteWithWhere:(NSString *)where clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.dbOperation deleteWithWhere:where classInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
    } else {
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
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
    id rowIdentifyValue = [model valueForKey:classInfo.rowIdentifyPropertyName];
    if(!rowIdentifyValue) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.dbOperation updateWithModel:model classInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        });
        
    } else {
        [self.dbOperation updateWithModel:model classInfo:classInfo resultBlock:^(BOOL success) {
            if(resultBlock) {
                resultBlock(success);
            }
        }];
    }
}

- (void)updateWithModels:(NSArray *)models clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    NSMutableArray *resultArray = [NSMutableArray array];
    if(async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
    }
}

- (BOOL)clearTable:(Class)clazz
{
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
    if(!classInfo.tableName) return NO;
    return [self.dbOperation clearTable:classInfo.tableName];
}

@end

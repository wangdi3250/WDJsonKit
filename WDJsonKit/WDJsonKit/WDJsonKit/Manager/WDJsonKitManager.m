//
//  WDJsonKitManager.m
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDJsonKitManager.h"
#import "WDJsonKitCache.h"
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

#pragma mark - 工具方法
- (WDClassInfo *)classInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = [self.cache classInfoFromCache:clazz];
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
            WDPropertyInfo *propertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:property];
            if(!propertyWhiteList.count && !propertyBlackList.count) {
                [classInfo.propertyCache addObject:propertyInfo];
            } else if((propertyWhiteList.count && [propertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.propertyCache addObject:propertyInfo];
            } else if(propertyBlackList.count && ![propertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.propertyCache addObject:propertyInfo];
            }
            [propertyInfo wd_setupkeysMappingWithMappingDict:mappingDict];
            [propertyInfo wd_setupClassInArrayWithClassInArrayDict:classInArrayDict];
        }
        if(propertys) {
            free(propertys);
        }
        [self.cache saveClassInfoToCache:classInfo class:clazz];
    }
    return classInfo;
}

- (WDClassInfo *)sqlClassInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = [self.cache sqlClassInfoFromCache:clazz];
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
        
        NSAssert([clazz respondsToSelector:@selector(wd_sqlRowIdentifyPropertyName)], @"错误：%@ 想要使用数据持久化，必须实现（wd_sqlRowIdentifyPropertyName）方法返回模型的标识字段的名字",classInfo.name);
        classInfo.rowIdentifyPropertyName = [clazz wd_sqlRowIdentifyPropertyName];
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:property];
            if(!sqlPropertyWhiteList.count && !sqlPropertyBlackList.count) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            } else if((sqlPropertyWhiteList.count && [sqlPropertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            } else if(sqlPropertyBlackList.count && ![sqlPropertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            }
            [propertyInfo wd_setupSQLClassInArrayWithSQLClassInArrayDict:sqlClassInArrayDict];
            [propertyInfo wd_setupSQLKeysMappingWithSQLMappingDict:sqlMappingDict];
            if([propertyInfo.name isEqualToString:classInfo.rowIdentifyPropertyName]) {
                classInfo.rowIdentityColumnName = propertyInfo.sqlColumnName;
            }
        }
        if(propertys) {
            free(propertys);
        }
        NSAssert(classInfo.rowIdentityColumnName && classInfo.rowIdentifyPropertyName, @"错误：rowIdentityColumnName 或者rowIdentifyPropertyName 不能为空，请检查 %@类 是否实现（wd_sqlRowIdentifyPropertyName）方法",classInfo.name);
        [self.cache sqlSaveClassInfoToCache:classInfo class:clazz];
    }
    return classInfo;
}

- (WDClassInfo *)encodingClassInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = [self.cache encodingClassInfoFromCache:clazz];
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
            WDPropertyInfo *propertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:property];
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
        [self.cache encodingSaveClassInfoToCache:classInfo class:clazz];
    }
    return classInfo;
}

- (void)saveWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    WDClassInfo *classInfo = [self sqlClassInfoFromCache:[model class]];
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
    WDClassInfo *classInfo = [self sqlClassInfoFromCache:[model class]];
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
    WDClassInfo *classInfo = [self sqlClassInfoFromCache:clazz];
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

- (void)queryWithRowIdentify:(id)identify clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *))resultBlock
{
    WDClassInfo *classInfo = [self sqlClassInfoFromCache:clazz];
    NSString *where = [NSString stringWithFormat:@"%@ = %@",classInfo.rowIdentityColumnName,identify];
    [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil clazz:clazz async:async resultBlock:resultBlock];
}

- (void)deleteWithWhere:(NSString *)where clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock
{
    WDClassInfo *classInfo = [self sqlClassInfoFromCache:clazz];
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
    WDClassInfo *classInfo = [self sqlClassInfoFromCache:clazz];
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

@end

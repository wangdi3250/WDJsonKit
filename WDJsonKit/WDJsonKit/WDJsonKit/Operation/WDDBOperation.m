//
//  WDDBOperation.m
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDDBOperation.h"
#import "WDClassInfo.h"
#import "NSString+WDJsonKit.h"
#import "WDJsonKitConst.h"
#import "WDPropertyInfo.h"
#import "WDFMDBManager.h"
#import "NSObject+WDJsonKit.h"
#import "WDPropertyTypeInfo.h"
#import "WDJsonKitCache.h"
#import "NSDate+WDJsonKit.h"
#import "WDJsonKitManager.h"

@implementation WDDBOperation

static id _instance;

+ (instancetype)sharedOperation
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

- (void)insertWithClassInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL))resultBlock
{
    if(!classInfo.object || !classInfo.tableName) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    if(![[WDJsonKitManager sharedManager].cache containsTableName:classInfo.tableName]) {
        BOOL success = [self createTableWithclassInfo:classInfo];
        if(!success) {
            if(resultBlock) {
                resultBlock(NO);
            }
            return;
        }
    }
    [self insertOperationWithClassInfo:classInfo isInsert:YES resultBlock:resultBlock];
}

- (void)saveWithClassInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL))resultBlock
{
    if(!classInfo.object || !classInfo.tableName) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    //判断是否存在这条记录
    id rowIdValue = [classInfo.object valueForKey:classInfo.rowIdentifyPropertyName];
    if(!rowIdValue) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    if(![[WDJsonKitManager sharedManager].cache containsTableName:classInfo.tableName]) {
        BOOL success = [self createTableWithclassInfo:classInfo];
        if(!success) {
            if(resultBlock) {
                resultBlock(NO);
            }
            return;
        }
    }
    NSString *where = [NSString stringWithFormat:@"%@ = %@",classInfo.rowIdentityColumnName,rowIdValue];
    [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil classInfo:classInfo resultBlock:^(NSArray *result) {
        if(result.count) { //数据库中已经存在一条这样的记录，执行更新操作
            [self updateWithModel:classInfo.object classInfo:classInfo resultBlock:^(BOOL success) {
                if(resultBlock) {
                    resultBlock(success);
                }
            }];
        } else { //执行插入操作
            [self insertOperationWithClassInfo:classInfo isInsert:NO resultBlock:resultBlock];
        }
    }];
}

- (void)insertOperationWithClassInfo:(WDClassInfo *)classInfo isInsert:(BOOL)isInsert resultBlock:(void (^)(BOOL success))resultBlock
{
    NSMutableString *columns = [NSMutableString string];
    NSMutableString *placeString = [NSMutableString string];
    NSMutableArray *values = [NSMutableArray array];
    for(WDPropertyInfo *propertyInfo in classInfo.sqlPropertyCache) {
        NSString *columnName = propertyInfo.sqlColumnName;
        if([propertyInfo.name isEqualToString:WDaID]) {
            [columns appendFormat:@"%@,",columnName];
            [placeString appendString:@"?,"];
            if(!classInfo.wd_aID) {
                classInfo.wd_aID = [NSNull null];
            }
            [values addObject:classInfo.wd_aID];
            continue;
        }
        id value = [classInfo.object valueForKey:propertyInfo.name];
        if(!value) value = [NSNull null];
        Class typeClazz = propertyInfo.type.typeClass;
        if(typeClazz && !propertyInfo.type.isFromFoundation) { //自定义对象类型
            if(propertyInfo.isSqlIgnoreBuildNewTable) {
                if(![value isKindOfClass:[NSNull class]]) {
                    value = [NSKeyedArchiver archivedDataWithRootObject:value];
                }
                [columns appendFormat:@"%@,",columnName];
                [placeString appendString:@"?,"];
                [values addObject:value];
            } else {
                if([value isKindOfClass:[NSNull class]]) continue;
                [self setupCustomerTypeWithArray:@[value] classInfo:classInfo resultModel:nil isInsert:isInsert resultBlock:^(BOOL success) {
                    if(!success) {
                        if(resultBlock) {
                            resultBlock(NO);
                        }
                        return ;
                    }
                }];
            }
        } else if(typeClazz && [value isKindOfClass:[NSArray class]]) {
            if(propertyInfo.sqlArrayClazz) { //数据里面装的是对象
                if(propertyInfo.isSqlIgnoreBuildNewTable) {
                    if(![value isKindOfClass:[NSNull class]]) {
                        value = [NSKeyedArchiver archivedDataWithRootObject:value];
                    }
                    [columns appendFormat:@"%@,",columnName];
                    [placeString appendString:@"?,"];
                    [values addObject:value];
                } else {
                    if([value isKindOfClass:[NSNull class]]) continue;
                    [self setupCustomerTypeWithArray:value classInfo:classInfo resultModel:nil isInsert:isInsert resultBlock:^(BOOL success) {
                        if(!success) {
                            if(resultBlock) {
                                resultBlock(NO);
                            }
                            return ;
                        }
                    }];
                }
            } else { //数组里面装的不是对象
                if(![value isKindOfClass:[NSNull class]]) {
                    value = [NSKeyedArchiver archivedDataWithRootObject:value];
                }
                [columns appendFormat:@"%@,",columnName];
                [placeString appendString:@"?,"];
                [values addObject:value];
            }
        } else {
            if(typeClazz == [NSURL class] && [value isKindOfClass:[NSURL class]]) {
                value = [(NSURL *)value absoluteString];
            } else if(typeClazz == [NSDate class] && [value isKindOfClass:[NSDate class]]) {
                value = [((NSDate *)value) wd_dateStringWithDateFormatter:@"yyyy-MM-dd HH:mm:ss"];
            } else if([typeClazz isSubclassOfClass:[NSDictionary class]] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            }
            [columns appendFormat:@"%@,",columnName];
            [placeString appendString:@"?,"];
            [values addObject:value];
        }
        
    }
    NSString *resultColumns = nil;
    NSString *resultValues = nil;
    if(columns.length > 1) {
        resultColumns = [columns substringToIndex:columns.length - 1];
    }
    if(placeString.length > 1) {
        resultValues = [placeString substringToIndex:placeString.length - 1];
    }
    if(!resultColumns || !resultValues) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(%@);",classInfo.tableName,resultColumns,resultValues];
    BOOL success = [[WDFMDBManager sharedManager] executeUpdate:sql argumentsInArray:values];
    if(resultBlock) {
        resultBlock(success);
    }
}

- (void)queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(NSArray *))resultBlock
{
    if(![[WDJsonKitManager sharedManager].cache containsTableName:classInfo.tableName]) {
        BOOL success = [self createTableWithclassInfo:classInfo];
        if(!success) {
            if(resultBlock) {
                resultBlock(nil);
            }
            return;
        }
    }
    NSMutableString *tmpSQL=[NSMutableString stringWithFormat:@"SELECT * FROM %@",classInfo.tableName];
    if(where) [tmpSQL appendFormat:@" WHERE %@",where];
    if(groupBy) [tmpSQL appendFormat:@" GROUP BY %@",groupBy];
    if(orderBy) [tmpSQL appendFormat:@" ORDER BY %@",orderBy];
    if(limit) [tmpSQL appendFormat:@" LIMIT %@",limit];
    NSString *sql=[NSString stringWithFormat:@"%@;",tmpSQL];
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *propertys = [NSMutableArray array];
    [[WDFMDBManager sharedManager] executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        while ([set next]) {
            NSObject *model = [[classInfo.clazz alloc] init];
            [result addObject:model];
            id aID = nil;
            if(classInfo.rowIdentityColumnName) {
                aID = [set objectForColumnName:classInfo.rowIdentityColumnName];
            }
            if(aID && ![aID isKindOfClass:[NSNull class]]) {
                model.wd_aID = aID;
            }
            for(WDPropertyInfo *propertyInfo in classInfo.sqlPropertyCache) {
                if([propertyInfo.name isEqualToString:WDaID]) continue;
                id value = nil;
                if(propertyInfo.sqlColumnName) {
                    value = [set objectForColumnName:propertyInfo.sqlColumnName];
                }
                Class typeClazz = propertyInfo.type.typeClass;
                if(!propertyInfo.type.isFromFoundation && typeClazz) { //自定义模型
                    if(propertyInfo.isSqlIgnoreBuildNewTable && [value isKindOfClass:[NSData class]]) {
                        value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
                        if(value) {
                            [model setValue:value forKey:propertyInfo.name];
                        }
                    } else {
                        if(![propertys containsObject:propertyInfo]) {
                            [propertys addObject:propertyInfo];
                        }
                    }
                } else if(typeClazz && [typeClazz isSubclassOfClass:[NSArray class]]) { //数组类型
                    if(propertyInfo.sqlArrayClazz) { //数组里面是自定义对象类型
                        if(propertyInfo.isSqlIgnoreBuildNewTable && [value isKindOfClass:[NSData class]]) {
                            value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
                            if(value) {
                                [model setValue:value forKey:propertyInfo.name];
                            }
                        } else {
                            if(![propertys containsObject:propertyInfo]) {
                                [propertys addObject:propertyInfo];
                            }
                        }
                    } else if([value isKindOfClass:[NSData class]]) { //数组里面放的不是自定义对象类型
                        value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
                        if(value) {
                            [model setValue:value forKey:propertyInfo.name];
                        }
                    }
                } else {
                    if(!value) continue;
                    if([typeClazz isSubclassOfClass:[NSString class]]) {
                        if(typeClazz == [NSMutableString class]) {
                            if([value isKindOfClass:[NSNumber class]]) {
                                value = [NSMutableString stringWithString:[value description]];
                            } else if([value isKindOfClass:[NSString class]]) {
                                value = [NSMutableString stringWithString:value];
                            }
                        } else {
                            if([value isKindOfClass:[NSNumber class]]) {
                                value = [value description];
                            }
                        }
                    } else if(typeClazz == [NSURL class]) {
                        if([value isKindOfClass:[NSString class]]) {
                            
                            value = [(NSString *)value wd_url];
                        }
                    } else if(typeClazz == [NSDate class]) {
                        if([value isKindOfClass:[NSString class]]) {
                            value = [(NSString *)value wd_dateWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                        }
                    } else if(typeClazz == [NSMutableData class]) {
                        value = [NSMutableData dataWithData:value];
                    } else if([typeClazz isSubclassOfClass:[NSDictionary class]] && [value isKindOfClass:[NSData class]]) {
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:value options:NSJSONReadingAllowFragments error:nil];
                        if(!dict) continue;
                        if(typeClazz == [NSMutableDictionary class]) {
                            value = [NSMutableDictionary dictionaryWithDictionary:dict];
                            
                        } else {
                            value = dict;
                        }
                    }
                    if(value && ![value isKindOfClass:[NSNull class]]) {
                        [model setValue:value forKey:propertyInfo.name];
                    }
                }
            }
        }
    }];
    
    for(NSObject *model in result) {
        if(!model.wd_aID) continue;
        for(WDPropertyInfo *propertyInfo in propertys) {
            Class typeClazz = propertyInfo.type.typeClass;
            if(!propertyInfo.type.isFromFoundation && typeClazz) { //自定义模型类型
                WDClassInfo *subClassInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:typeClazz];
                NSString *where = [NSString stringWithFormat:@"%@ = %@",WDaID,model.wd_aID];
                [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil classInfo:subClassInfo resultBlock:^(NSArray *result) {
                    if(result.count) {
                        [model setValue:result.firstObject forKey:propertyInfo.name];
                    }
                }];
                
            } else { //数组类型
                NSArray *array = [self setupQueryArrayWithClassInfo:classInfo clazzInArray:propertyInfo.sqlArrayClazz aID:model.wd_aID];
                if(array.count) {
                    if(typeClazz == [NSMutableArray class]) {
                        array = [NSMutableArray arrayWithArray:array];
                    } else {
                        array = [NSArray arrayWithArray:array];
                    }
                    [model setValue:array forKey:propertyInfo.name];
                }
            }
        }
    }
    if(resultBlock) {
        resultBlock(result);
    }
}

- (void)deleteWithWhere:(NSString *)where classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL))resultBlock
{
    if(![[WDJsonKitManager sharedManager].cache containsTableName:classInfo.tableName]) {
        BOOL success = [self createTableWithclassInfo:classInfo];
        if(!success) {
            if(resultBlock) {
                resultBlock(NO);
            }
            return;
        }
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",classInfo.tableName];
    if(where) {
        sql = [NSString stringWithFormat:@"%@ WHERE %@",sql,where];
    }
    sql = [NSString stringWithFormat:@"%@;",sql];
    [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil classInfo:classInfo resultBlock:^(NSArray *result) {
        if(!result || !result.count) {
            if(resultBlock) {
                resultBlock(YES);
                return;
            }
        }
        for(NSObject *model in result) {
            WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:[model class]];
            for(WDPropertyInfo *propertyInfo in classInfo.sqlPropertyCache) {
                Class typeClazz = propertyInfo.type.typeClass;
                if(typeClazz && !propertyInfo.type.isFromFoundation && !propertyInfo.isSqlIgnoreBuildNewTable) { //自定义对象
                    if(!model.wd_aID || [model.wd_aID isKindOfClass:[NSNull class]]) continue;
                    NSString *subWhere = [NSString stringWithFormat:@"%@ = %@",WDaID,model.wd_aID];
                    WDClassInfo *subClassInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:typeClazz];
                    [self deleteWithWhere:subWhere classInfo:subClassInfo resultBlock:^(BOOL success) {
                        if(!success) {
                            if(resultBlock) {
                                resultBlock(NO);
                            }
                            return;
                        }
                    }];
                } else if(typeClazz && [typeClazz isSubclassOfClass:[NSArray class]]) { //数组类型
                    if(propertyInfo.sqlArrayClazz) {
                        if(!propertyInfo.isSqlIgnoreBuildNewTable) {
                            if(!model.wd_aID || [model.wd_aID isKindOfClass:[NSNull class]]) continue;
                            NSString *subWhere = [NSString stringWithFormat:@"%@ = %@",WDaID,model.wd_aID];
                            WDClassInfo *subClassInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:propertyInfo.sqlArrayClazz];
                            [self deleteWithWhere:subWhere classInfo:subClassInfo resultBlock:^(BOOL success) {
                                if(!success) {
                                    if(resultBlock) {
                                        resultBlock(NO);
                                    }
                                    return;
                                }
                            }];
                        }
                    }
                }
            }
            BOOL success = [[WDFMDBManager sharedManager] executeUpdate:sql];
            if(resultBlock) {
                resultBlock(success);
            }
        }
    }];
}

- (void)updateWithModel:(NSObject *)model classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL))resultBlock
{
    if(![[WDJsonKitManager sharedManager].cache containsTableName:classInfo.tableName]) {
        BOOL success = [self createTableWithclassInfo:classInfo];
        if(!success) {
            if(resultBlock) {
                resultBlock(NO);
            }
            return;
        }
    }
    id rowIdentifyId = [model valueForKey:classInfo.rowIdentifyPropertyName];
    if(!rowIdentifyId) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    NSMutableString *where = [NSMutableString string];
    [where appendFormat:@"%@ = %@",classInfo.rowIdentityColumnName,rowIdentifyId];
    if(model.wd_aID && ![model.wd_aID isKindOfClass:[NSNull class]]) {
        [where appendFormat:@" AND %@ = %@",WDaID,model.wd_aID];
    }
    NSMutableString *keyValueString=[NSMutableString string];
    NSMutableArray *values = [NSMutableArray array];
    [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil classInfo:classInfo resultBlock:^(NSArray *result) {
        if(result.count == 0) {
            if(resultBlock) {
                resultBlock(NO);
            }
            return;
        }
        for(WDPropertyInfo *propertyInfo in classInfo.sqlPropertyCache) {
            if([propertyInfo.name isEqualToString:WDaID]) continue;
            id value = [model valueForKey:propertyInfo.name];
            if(!value) value = [NSNull null];
            Class typeClazz = propertyInfo.type.typeClass;
            if(typeClazz && !propertyInfo.type.isFromFoundation) { //自定义对象类型
                if(propertyInfo.isSqlIgnoreBuildNewTable) {
                    [keyValueString appendFormat:@"%@ = ?,",propertyInfo.sqlColumnName];
                    value = [NSKeyedArchiver archivedDataWithRootObject:value];
                    [values addObject:value];
                } else {
                    WDClassInfo *subClassInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:typeClazz];
                    NSObject *obj = (NSObject *)value;
                    NSObject *sqlObj = result.firstObject;
                    obj.wd_aID = sqlObj.wd_aID;
                    [self updateWithModel:obj classInfo:subClassInfo resultBlock:^(BOOL success) {
                        if(!success) {
                            if(resultBlock) {
                                resultBlock(NO);
                            }
                            return;
                        }
                    }];
                }
            } else if(typeClazz && [typeClazz isSubclassOfClass:[NSArray class]]) { //数组类型
                if(propertyInfo.sqlArrayClazz) { //数组里面装的自定义对象
                    if(propertyInfo.isSqlIgnoreBuildNewTable) {
                        [keyValueString appendFormat:@"%@ = ?,",propertyInfo.sqlColumnName];
                        if(![value isKindOfClass:[NSNull class]]) {
                            value = [NSKeyedArchiver archivedDataWithRootObject:value];
                        }
                        if(value) {
                            [values addObject:value];
                        }
                    } else {
                        NSArray *modelArray = (NSArray *)value;
                        [self setupCustomerTypeWithArray:modelArray classInfo:classInfo resultModel:result.firstObject isInsert:NO resultBlock:^(BOOL success) {
                            if(!success) {
                                if(resultBlock) {
                                    resultBlock(NO);
                                }
                                return ;
                            }
                        }];
                    }
                } else { //数组里面装的不是自定义对象
                    [keyValueString appendFormat:@"%@ = ?,",propertyInfo.sqlColumnName];
                    value = [NSKeyedArchiver archivedDataWithRootObject:value];
                    if(value) {
                        [values addObject:value];
                    }
                }
            } else {
                [keyValueString appendFormat:@"%@ = ?,",propertyInfo.sqlColumnName];
                if(typeClazz == [NSURL class] && [value isKindOfClass:[NSURL class]]) {
                    value = [(NSURL *)value absoluteString];
                } else if(typeClazz == [NSDate class] && [value isKindOfClass:[NSDate class]]) {
                    value = [((NSDate *)value) wd_dateStringWithDateFormatter:@"yyyy-MM-dd HH:mm:ss"];
                } else if([typeClazz isSubclassOfClass:[NSDictionary class]] && [value isKindOfClass:[NSDictionary class]]) {
                    value = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
                }
                [values addObject:value];
            }
        }
        
        if(keyValueString.length > 1) {
            NSString *newKeyValue = [keyValueString substringToIndex:keyValueString.length - 1];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;",classInfo.tableName,newKeyValue,where];
            BOOL success = [[WDFMDBManager sharedManager] executeUpdate:sql argumentsInArray:values];
            if(resultBlock) {
                resultBlock(success);
            }
        }
    }];
}

- (void)setupCustomerTypeWithArray:(NSArray *)array classInfo:(WDClassInfo *)classInfo resultModel:(NSObject *)resultModel isInsert:(BOOL)isInsert resultBlock:(void (^)(BOOL success))resultBlock
{
    if(!array.count || !classInfo.tableName) {
        if(resultBlock) {
            resultBlock(NO);
        }
        return;
    }
    for(id obj in array) {
        if(![WDClassInfo classFromFoundation:[obj class]]) {
            WDClassInfo *subClassInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:[obj class]];
            if(!resultModel) { //插入
                id aID = [classInfo.object valueForKey:classInfo.rowIdentifyPropertyName];
                subClassInfo.wd_aID = aID;
            } else { //更新
                subClassInfo.wd_aID = resultModel.wd_aID;
            }
            subClassInfo.object = obj;
            if(isInsert) {
                [self insertWithClassInfo:subClassInfo resultBlock:^(BOOL success) {
                    if(!success) {
                        if(resultBlock) {
                            resultBlock(NO);
                        }
                    }
                }];
            } else {
                [self saveWithClassInfo:subClassInfo resultBlock:^(BOOL success) {
                    if(!success) {
                        if(resultBlock) {
                            resultBlock(NO);
                        }
                    }
                }];
            }
        }
    }
}

- (NSArray *)setupQueryArrayWithClassInfo:(WDClassInfo *)classInfo clazzInArray:(Class)clazzInArray aID:(id)aID
{
    __block NSArray *res = nil;
    WDClassInfo *subClassInfo = [[WDJsonKitManager sharedManager].cache sqlClassInfoFromCache:clazzInArray];
    NSString *where = [NSString stringWithFormat:@"%@ = %@",WDaID,aID];
    [self queryWithWhere:where groupBy:nil orderBy:nil limit:nil classInfo:subClassInfo resultBlock:^(NSArray *result) {
        res = result;
    }];
    return res;
    
}

- (BOOL)tableIsCreate:(NSString *)tableName
{
    return [[WDFMDBManager sharedManager] tableIsExists:tableName];
}

- (BOOL)createTableWithclassInfo:(WDClassInfo *)classInfo
{
    if([self tableIsCreate:classInfo.tableName]) {
        [self checkpropertyIsChangeWithClassInfo:classInfo];
        return YES;
    }
    NSMutableString *sql=[NSMutableString string];
    [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT 0,",classInfo.tableName];
    for(WDPropertyInfo *propertyInfo in classInfo.sqlPropertyCache) {
        NSString *sqlColumnType = propertyInfo.sqlColumnTypeDesc;
        NSString *sqlColumnName = propertyInfo.sqlColumnName;
        if(!sqlColumnType.length || !sqlColumnName.length) continue;
        [sql appendFormat:@"%@ %@,",sqlColumnName,sqlColumnType];
    }
    NSString *resultSql = [sql substringToIndex:sql.length - 1];
    resultSql = [NSString stringWithFormat:@"%@);",resultSql];
    BOOL result = [[WDFMDBManager sharedManager] executeUpdate:resultSql];
    if(result) {
        [[WDJsonKitManager sharedManager].cache saveTableName:classInfo.tableName];
    }
    return result;
}

- (void)clearTable:(NSString *)tableName resultBlock:(void (^)(BOOL))resultBlock
{
    BOOL success = [[WDFMDBManager sharedManager] clearTable:tableName];
    if([[WDJsonKitManager sharedManager].cache containsTableName:tableName]) {
        [[WDJsonKitManager sharedManager].cache removeTableName:tableName];
    }
    if(resultBlock) {
        resultBlock(success);
    }
}

- (void)checkpropertyIsChangeWithClassInfo:(WDClassInfo *)classInfo
{
    if(!classInfo) return;
    [[WDFMDBManager sharedManager] executeQueryColumnsInTable:classInfo.tableName];
    NSMutableArray *columns = [NSMutableArray arrayWithArray:[[WDFMDBManager sharedManager] executeQueryColumnsInTable:classInfo.tableName]];
    [columns removeObject:@"id"];
    if(columns.count >= classInfo.sqlPropertyCache.count) return;
    for(WDPropertyInfo *propertyInfo in classInfo.sqlPropertyCache) {
        if([columns containsObject:propertyInfo.sqlColumnName]) continue;
        if(propertyInfo.type.typeClass && !propertyInfo.type.isFromFoundation && !propertyInfo.isSqlIgnoreBuildNewTable) continue;
        if(propertyInfo.type.typeClass && propertyInfo.sqlArrayClazz && !propertyInfo.sqlArrayClazzFromFoundation && !propertyInfo.isSqlIgnoreBuildNewTable) continue;
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD COLUMN %@ %@;",classInfo.tableName,propertyInfo.sqlColumnName,propertyInfo.sqlColumnTypeDesc];
        [[WDFMDBManager sharedManager] executeUpdate:sql];
        
    }
}

@end

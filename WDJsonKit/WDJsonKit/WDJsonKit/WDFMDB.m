//
//  WDFMDB.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/3.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDFMDB.h"
#import "WDJsonKitConst.h"
#import "NSString+WDJsonKit.h"

@interface WDFMDB()

@property (nonatomic, strong) FMDatabaseQueue *dataBaseQueue;

@end

@implementation WDFMDB

static id _instance;

+ (void)initialize
{
    [self wd_setupDBWithPath:[self wd_dbPathWithDBName:WDDBName]];
}

+ (instancetype)sharedFMDB
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

+ (NSString*)wd_dbPathWithDBName:(NSString*)dbName
{
    if(!dbName) return nil;
    NSString* fileName = nil;
    if (![dbName hasSuffix:@".db"]) {
        fileName = [NSString stringWithFormat:@"%@.db", dbName];
    } else {
        fileName = dbName;
    }
    NSString *dirPath = [@"db" wd_appendDocumentPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"%@",[dirPath stringByAppendingPathComponent:fileName]);
    return [dirPath stringByAppendingPathComponent:fileName];
}

+ (void)wd_setupDBWithPath:(NSString *)path
{
    if(!path) return;
    WDFMDB *mySelf = [WDFMDB sharedFMDB];
    FMDatabaseQueue *dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    mySelf.dataBaseQueue = dataBaseQueue;
}

+ (BOOL)wd_executeUpdate:(NSString *)sql
{
    __block BOOL result = NO;
    if(!sql) return result;
    [[WDFMDB sharedFMDB].dataBaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

+ (BOOL)wd_executeUpdate:(NSString *)sql argumentsInArray:(NSArray *)array
{
    __block BOOL result = NO;
    if(!array.count || !sql) return result;
    [[WDFMDB sharedFMDB].dataBaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql withArgumentsInArray:array];
    }];
    return result;
}

+ (void)wd_executeQuery:(NSString *)sql queryResultBlock:(queryResultBlock)queryResultBlock
{
    [[WDFMDB sharedFMDB].dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        if(queryResultBlock) {
            queryResultBlock(set);
        }
        [set close];
    }];
}

+ (BOOL)wd_tableIsExists:(NSString *)tableName
{
    if(!tableName) return NO;
    NSString *alias=@"tableCount";
    NSString *sql=[NSString stringWithFormat:@"SELECT COUNT(*) %@ FROM sqlite_master WHERE type='table' AND name='%@';",alias,tableName];
    __block BOOL isCreate = NO;
    [self wd_executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        if([set next] && [set intForColumnIndex:0] > 0) {
            isCreate = YES;
        }
    }];
    return isCreate;
}

+ (NSInteger)wd_lastInsertRowIdWithTableName:(NSString *)tableName
{
    __block NSInteger lastInsertRowId = 0;
    if(!tableName) return lastInsertRowId;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY id DESC;",tableName];
    [self wd_executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        if([set next]) {
            lastInsertRowId = [set intForColumn:@"id"];
        }
    }];
    return lastInsertRowId;
}

+(NSArray *)wd_executeQueryColumnsInTable:(NSString *)tableName
{
    
    NSMutableArray *columns=[NSMutableArray array];
    NSString *sql=[NSString stringWithFormat:@"PRAGMA table_info (%@);",tableName];
    [self wd_executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        while ([set next]) {
            NSString *column = [set stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return [columns copy];
}

+ (BOOL)wd_clearTable:(NSString *)tableName
{
    if(!tableName) return NO;
    BOOL res = [self wd_executeUpdate:[NSString stringWithFormat:@"DELETE FROM '%@'", tableName]];
    [self wd_executeUpdate:[NSString stringWithFormat:@"DELETE FROM sqlite_sequence WHERE name='%@';", tableName]];
    return res;
}

@end

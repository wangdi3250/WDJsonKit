//
//  WDFMDBManager.m
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDFMDBManager.h"
#import "WDJsonKitConst.h"
#import "NSString+WDJsonKit.h"

@interface WDFMDBManager()

@property (nonatomic, strong) FMDatabaseQueue *dataBaseQueue;

@end

@implementation WDFMDBManager

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
        _dbPath = [self dbPathWithDBName:WDDBName];
        [self setupDBWithPath:_dbPath];
    }
    return self;
}

- (NSString*)dbPathWithDBName:(NSString*)dbName
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

- (void)setupDBWithPath:(NSString *)path
{
    if(!path) return;
    FMDatabaseQueue *dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    self.dataBaseQueue = dataBaseQueue;
}

- (BOOL)executeUpdate:(NSString *)sql
{
    __block BOOL result = NO;
    if(!sql) return result;
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (BOOL)executeUpdate:(NSString *)sql argumentsInArray:(NSArray *)array
{
    __block BOOL result = NO;
    if(!array.count || !sql) return result;
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql withArgumentsInArray:array];
    }];
    return result;
}

- (void)executeQuery:(NSString *)sql queryResultBlock:(queryResultBlock)queryResultBlock
{
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        if(queryResultBlock) {
            queryResultBlock(set);
        }
        [set close];
    }];
}

- (BOOL)tableIsExists:(NSString *)tableName
{
    if(!tableName) return NO;
    NSString *alias=@"tableCount";
    NSString *sql=[NSString stringWithFormat:@"SELECT COUNT(*) %@ FROM sqlite_master WHERE type='table' AND name='%@';",alias,tableName];
    __block BOOL isCreate = NO;
    [self executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        if([set next] && [set intForColumnIndex:0] > 0) {
            isCreate = YES;
        }
    }];
    return isCreate;
}

- (NSInteger)lastInsertRowIdWithTableName:(NSString *)tableName
{
    __block NSInteger lastInsertRowId = 0;
    if(!tableName) return lastInsertRowId;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY id DESC;",tableName];
    [self executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        if([set next]) {
            lastInsertRowId = [set intForColumn:@"id"];
        }
    }];
    return lastInsertRowId;
}

-(NSArray *)executeQueryColumnsInTable:(NSString *)tableName
{
    
    NSMutableArray *columns=[NSMutableArray array];
    NSString *sql=[NSString stringWithFormat:@"PRAGMA table_info (%@);",tableName];
    [self executeQuery:sql queryResultBlock:^(FMResultSet *set) {
        while ([set next]) {
            NSString *column = [set stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return [columns copy];
}

- (BOOL)clearTable:(NSString *)tableName
{
    if(!tableName) return NO;
    BOOL res = [self executeUpdate:[NSString stringWithFormat:@"DELETE FROM '%@'", tableName]];
    [self executeUpdate:[NSString stringWithFormat:@"DELETE FROM sqlite_sequence WHERE name='%@';", tableName]];
    return res;
}

@end

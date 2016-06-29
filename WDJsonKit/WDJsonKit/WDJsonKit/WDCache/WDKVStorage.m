//
//  WDKVStorage.m
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import "WDKVStorage.h"
#import "FMDB.h"
#import <time.h>

static NSString * const kDBFileName = @"cache.db";
static NSString * const kDataName = @"cacheData";
static NSString * const kTrashName = @"trashData";
static NSString * const kDBTableName = @"WDCacheTable";
#define kFileDataFullPath(key) [self.dataPath stringByAppendingPathComponent:(key)]

@implementation WDKVStorageItem

@end

@interface WDKVStorage()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, copy) NSString *dataPath;
@property (nonatomic, copy) NSString *trashPath;
@property (nonatomic, strong) dispatch_queue_t trashQueue;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation WDKVStorage

- (instancetype)initWithPath:(NSString *)path
{
    NSAssert(path.length, @"路径不能为空");
    if(self =[super init]) {
        _path = [path copy];
        _dbPath = [path stringByAppendingPathComponent:kDBFileName];
        _dataPath = [path stringByAppendingPathComponent:kDataName];
        _trashPath = [path stringByAppendingPathComponent:kTrashName];
        _trashQueue = dispatch_queue_create("com.wd.trash", DISPATCH_QUEUE_SERIAL);
        if(self.dbQueue) {
            [self closeDB];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:_trashPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self openDB];
    }
    return self;
}

- (BOOL)removeItemsToFitCount:(NSUInteger)count
{
    if(count >= NSUIntegerMax) return YES;
    if(count <= 0) return [self removeAllItems];
    int totalCount = [self dbTotalItemsCount];
    if(totalCount < 0) return NO;
    if(totalCount <= count) return YES;
    NSArray *items = nil;
    BOOL success = NO;
    do {
        int perCount = 16;
        items = [self dbItemsByAccessTimeAscWithCount:perCount];
        for(WDKVStorageItem *item in items) {
            if(totalCount > count) {
                [self fileRemoveWithKey:item.fileName];
                success = [self dbRemoveItemWithKey:item.key];
                totalCount--;
            } else {
                break;
            }
            if(!success) break;
        }
    } while (totalCount > count && success && items.count);
    return success;
}

- (BOOL)removeItemsToFitSize:(NSUInteger)size
{
    if(size >= NSUIntegerMax) return YES;
    if(size <= 0) return [self removeAllItems];
    int totalSize = [self dbTotalItemsSize];
    if(totalSize <= 0) return NO;
    if(totalSize <= size) return YES;
    NSArray *items = nil;
    BOOL success = NO;
    do {
        int perCount = 16;
        items = [self dbItemsByAccessTimeAscWithCount:perCount];
        for(WDKVStorageItem *item in items) {
            if(totalSize > size) {
                [self fileRemoveWithKey:item.fileName];
                success = [self dbRemoveItemWithKey:item.key];
                totalSize -= item.size;
            } else {
                break;
            }
            if(!success) break;
        }
    } while (items.count && success && totalSize > size);
    return success;
}

- (BOOL)removeItemsThatMoreThanTime:(int)time
{
    if(time >= NSUIntegerMax) return YES;
    if(time <= 0) return [self removeAllItems];
    NSArray *fileNames = [self dbItemsFileNameThatMoreThanTime:time];
    for(NSString *fileName in fileNames) {
        [self fileRemoveWithKey:fileName];
    }
    
    return [self dbRemoveItemsThatMoreThanTime:time];
}

- (BOOL)removeAllItems
{
    return [self reset];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName
{
    if(!key.length || !value || !fileName.length) return NO;
    if(![self fileWriteWithKey:fileName data:value]) return NO;
    if(![self dbSaveWithKey:key value:value fileName:fileName]) {
        [self fileRemoveWithKey:key];
        return NO;
    }
    return YES;
}

- (WDKVStorageItem *)itemWithKey:(NSString *)key
{
    if(!key.length) return nil;
    WDKVStorageItem *item = [self dbItemWithKey:key];
    if(item) {
        item.value = [self fileReadWithKey:item.fileName];
        if(!item.value) {
            [self dbRemoveItemWithKey:key];
            item = nil;
        } else {
            [self dbUpdateAccessTimeWithKey:key];
            
        }
    }
    return item;
}

- (BOOL)removeItemWithKey:(NSString *)key
{
    if(!key.length) return NO;
    NSString *fileName = [self dbFileNameWithKey:key];
    if(fileName.length) {
        [self fileRemoveWithKey:fileName];
    }
    return [self dbRemoveItemWithKey:key];
}

- (BOOL)itemExistsWithKey:(NSString *)key
{
    if(!key.length) return NO;
    int count = [self dbItemCountWithKey:key];
    return count > 0;
}

- (BOOL)dbSaveWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName
{
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (key,fileName,size,accessTime) VALUES('%@','%@',%zd,%d);",kDBTableName,key,fileName,value.length,(int)time(NULL)];
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (WDKVStorageItem *)dbItemWithKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"SELECT key,fileName,size,accessTime FROM %@ WHERE key = '%@';",kDBTableName,key];
    __block WDKVStorageItem *item = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet  *resultSet = [db executeQuery:sql];
        if([resultSet next]) {
            item = [[WDKVStorageItem alloc] init];
            item.key = [resultSet stringForColumn:@"key"];
            item.fileName = [resultSet stringForColumn:@"fileName"];
            item.size = [resultSet intForColumn:@"size"];
            item.accessTime = [resultSet longForColumn:@"accessTime"];
        }
        [resultSet close];
    }];
    return item;
}

- (BOOL)dbRemoveItemWithKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE key = '%@';",kDBTableName,key];
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (BOOL)dbUpdateAccessTimeWithKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET accessTime = %d WHERE key = '%@';",kDBTableName,(int)time(NULL),key];
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (NSString *)dbFileNameWithKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"SELECT fileName FROM %@ WHERE key = '%@';",kDBTableName,key];
    __block NSString *fileName = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]) {
            fileName = [resultSet stringForColumn:@"fileName"];
        }
        [resultSet close];
    }];
    return fileName;
}

- (int)dbItemCountWithKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(key) FROM %@ WHERE key = '%@';",kDBTableName,key];
    __block int count = -1;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]) {
            count = [resultSet intForColumnIndex:0];
        }
        [resultSet close];
    }];
    return count;
}

- (int)dbTotalItemsCount
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;",kDBTableName];
    __block int totalCount = -1;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]) {
            totalCount = [resultSet intForColumnIndex:0];
        }
        [resultSet close];
    }];
    return totalCount;
}

- (int)dbTotalItemsSize
{
    NSString *sql = [NSString stringWithFormat:@"SELECT SUM(size) FROM %@;",kDBTableName];
    __block int size = -1;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]) {
            size = [resultSet intForColumnIndex:0];
        }
        [resultSet close];
    }];
    return size;
}

- (NSArray *)dbItemsByAccessTimeAscWithCount:(int)count
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY accessTime ASC LIMIT %d;",kDBTableName,count];
    NSMutableArray *items = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       FMResultSet *resultSet = [db executeQuery:sql];
        while([resultSet next]) {
            WDKVStorageItem *item = [[WDKVStorageItem alloc] init];
            item.key = [resultSet stringForColumn:@"key"];
            item.fileName = [resultSet stringForColumn:@"fileName"];
            item.accessTime = [resultSet longForColumn:@"accessTime"];
            item.size = [resultSet intForColumn:@"size"];
            [items addObject:item];
        }
        [resultSet close];
    }];
    return items;
}

- (NSArray *)dbItemsFileNameThatMoreThanTime:(int)time
{
    NSString *sql = [NSString stringWithFormat:@"SELECT fileName FROM %@ WHERE accessTime < %d;",kDBTableName,time];
    NSMutableArray *fileNames = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            NSString *fileName = [resultSet stringForColumn:@"fileName"];
            if(fileName) {
                [fileNames addObject:fileName];
            }
        }
        [resultSet close];
    }];
    return fileNames;
}

- (BOOL)dbRemoveItemsThatMoreThanTime:(int)time
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE accessTime < %d;",kDBTableName,time];
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       result = [db executeUpdate:sql];
    }];
    return result;
}

- (NSArray *)dbAllItemsFileName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT fileName FROM %@;",kDBTableName];
    NSMutableArray *fileNames = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            NSString *fileName = [resultSet stringForColumn:@"fileName"];
            if(fileName) {
                [fileNames addObject:fileName];
            }
        }
        [resultSet close];
    }];
    return fileNames;
}

- (BOOL)dbRemoveTableAllItems
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@;",kDBTableName];
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (BOOL)fileWriteWithKey:(NSString *)fileName data:(NSData *)data
{
    return [data writeToFile:kFileDataFullPath(fileName) atomically:YES];
    
}

- (NSData *)fileReadWithKey:(NSString *)fileName
{
    return [NSData dataWithContentsOfFile:kFileDataFullPath(fileName)];
}

- (BOOL)fileRemoveWithKey:(NSString *)fileName
{
    return [[NSFileManager defaultManager] removeItemAtPath:kFileDataFullPath(fileName) error:nil];
}

- (BOOL)fileMoveAllToTrash
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *tmpPath = [self.trashPath stringByAppendingPathComponent:(__bridge NSString *)(uuid)];
    BOOL suc = [[NSFileManager defaultManager] moveItemAtPath:self.dataPath toPath:tmpPath error:nil];
    if (suc) {
        suc = [[NSFileManager defaultManager] createDirectoryAtPath:self.dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    CFRelease(uuid);
    return suc;
}

- (void)fileEmptyTrashInBackground
{
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *directoryContents = [manager contentsOfDirectoryAtPath:trashPath error:NULL];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }
    });
}

#pragma mark - 数据库初始化相关操作
- (BOOL)createTable
{
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(key text primary key,fileName text,size integer,accessTime integer);",kDBTableName];
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (void)closeDB
{
    [self.dbQueue close];
    self.dbQueue = nil;
}

- (BOOL)openDB
{
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    if(!self.dbQueue) return NO;
    if(![self createTable]) return NO;
    return YES;
}

- (BOOL)reset
{
    [self.dbQueue close];
    [[NSFileManager defaultManager] removeItemAtPath:[self.path stringByAppendingPathComponent:kDBFileName] error:nil];
    if(![self fileMoveAllToTrash]) return NO;
    [self fileEmptyTrashInBackground];
    if(![self openDB]) return NO;
    return YES;
}

@end

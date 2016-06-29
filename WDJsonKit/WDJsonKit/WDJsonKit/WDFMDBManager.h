//
//  WDFMDBManager.h
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDFMDB.h"

@interface WDFMDBManager : NSObject

typedef void (^queryResultBlock)(FMResultSet *set);
/**
 *  最后一次插入的ID
 */
@property (nonatomic, assign) NSInteger lastInsertRowId;
@property (nonatomic, copy, readonly) NSString *dbPath;
/**
 *  单例方法
 *
 *  @return 单例对象
 */
+ (instancetype)sharedManager;
/**
 *  执行一个更新语句
 *
 *  @param sql 更新语句的sql
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)executeUpdate:(NSString *)sql;
/**
 *  执行一个更新语句
 *
 *  @param sql   更新语句的sql
 *  @param array 不确定的参数数组
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)executeUpdate:(NSString *)sql argumentsInArray:(NSArray *)array;
/**
 *  执行一个查询语句
 *
 *  @param sql              查询语句sql
 *  @param queryResultBlock    查询语句的执行结果
 */
- (void)executeQuery:(NSString *)sql queryResultBlock:(queryResultBlock)queryResultBlock;
/**
 *  判断表是否存在
 *
 *  @param tableName 表名
 *
 *  @return 存在返回YES，否者返回NO
 */
- (BOOL)tableIsExists:(NSString *)tableName;
/**
 *  取出表中最后一条记录
 *
 *  @param tableName 表名
 *
 *  @return 结果
 */
- (NSInteger)lastInsertRowIdWithTableName:(NSString *)tableName;
/**
 *  查询表的所有列
 *
 *  @param tableName 表名
 *
 *  @return 查询结果
 */
- (NSArray *)executeQueryColumnsInTable:(NSString *)tableName;
/**
 *  清空表，但不清空表结构
 *
 *  @param tableName 表名
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)clearTable:(NSString *)tableName;

@end

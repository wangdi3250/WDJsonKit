//
//  WDFMDB.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/3.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef void (^queryResultBlock)(FMResultSet *set);

@interface WDFMDB : NSObject
/**
 *  最后一次插入的ID
 */
@property (nonatomic, assign) NSInteger lastInsertRowId;
/**
 *  单例方法
 *
 *  @return 单例对象
 */
+ (instancetype)sharedFMDB;
/**
 *  执行一个更新语句
 *
 *  @param sql 更新语句的sql
 *
 *  @return 成功返回YES，失败返回NO
 */
+(BOOL)wd_executeUpdate:(NSString *)sql;
/**
 *  执行一个更新语句
 *
 *  @param sql   更新语句的sql
 *  @param array 不确定的参数数组
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)wd_executeUpdate:(NSString *)sql argumentsInArray:(NSArray *)array;
/**
 *  执行一个查询语句
 *
 *  @param sql              查询语句sql
 *  @param queryResultBlock    查询语句的执行结果
 */
+(void)wd_executeQuery:(NSString *)sql queryResultBlock:(queryResultBlock)queryResultBlock;
/**
 *  判断表是否存在
 *
 *  @param tableName 表名
 *
 *  @return 存在返回YES，否者返回NO
 */
+ (BOOL)wd_tableIsExists:(NSString *)tableName;
/**
 *  取出表中最后一条记录
 *
 *  @param tableName 表名
 *
 *  @return 结果
 */
+ (NSInteger)wd_lastInsertRowIdWithTableName:(NSString *)tableName;
/**
 *  查询表的所有列
 *
 *  @param tableName 表名
 *
 *  @return 查询结果
 */
+(NSArray *)wd_executeQueryColumnsInTable:(NSString *)tableName;
/**
 *  清空表，但不清空表结构
 *
 *  @param tableName 表名
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)wd_clearTable:(NSString *)tableName;

@end

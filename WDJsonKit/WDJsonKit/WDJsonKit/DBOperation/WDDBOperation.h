//
//  WDDBOperation.h
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDClassInfo;

@interface WDDBOperation : NSObject
/**
 *  单例方法
 *
 *  @return 对象本身
 */
+ (instancetype)sharedOperation;
/**
 *  插入一条记录，如果记录存在，执行更新操作
 *  @param classInfo   类的包装对象
 *  @param resultBlock 是否成功
 */
- (void)saveWithClassInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  插入一条记录，只是执行插入操作
 *
 *  @param classInfo   类的包装对象
 *  @param resultBlock 是否成功
 */
- (void)insertWithClassInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  条件查询
 *
 *  @param where       查询条件
 *  @param groupBy     分组条件
 *  @param orderBy     排序
 *  @param limit       分页
 @param async       是否开启线程
 @param classInfo   类的包装对象
 *  @param resultBlock 查询结果
 */
- (void)queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  删除操作
 *
 *  @param where 查询条件
 *  @param resultBlock 结果
 *  @param classInfo  类的包装对象
 */
- (void)deleteWithWhere:(NSString *)where classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  更新操作
 *
 *  @param model       要更新的模型
 *  @param classInfo   类的包装对象
 *  @param resultBlock 结果
 */
- (void)updateWithModel:(NSObject *)model classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;

/**
 *  删除表
 *
 *  @param tableName 表名
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)clearTable:(NSString *)tableName;

@end

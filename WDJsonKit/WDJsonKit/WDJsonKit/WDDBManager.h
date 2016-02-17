//
//  WDDBManager.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/1.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDClassInfo;
@interface WDDBManager : NSObject
/**
 *  单例
 *
 *  @return 单例对象
 */
+ (instancetype)sharedDBManager;
/**
 *  从缓存字典中取WDClassInfo对象
 *
 *  @param clazz 要取的类
 *
 *  @return WDClassInfo 对象
 */
+ (WDClassInfo *)wd_sqlClassInfoFromCache:(Class)clazz;
/**
 *  将WDClassInfo对象存到缓存字典中
 *
 *  @param classInfo WDClassInfo对象
 *  @param clazz     待缓存的类
 */
+ (void)wd_sqlSaveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz;
/**
 *  插入一条记录，如果记录存在，执行更新操作
 *  @param classInfo   类的包装对象
 *  @param resultBlock 是否成功
 */
+ (void)wd_saveWithClassInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  插入一条记录，只是执行插入操作
 *
 *  @param classInfo   类的包装对象
 *  @param resultBlock 是否成功
 */
+ (void)wd_insertWithClassInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;
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
+ (void)wd_queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  删除操作
 *
 *  @param where 查询条件
 *  @param resultBlock 结果
 *  @param classInfo  类的包装对象
 */
+ (void)wd_deleteWithWhere:(NSString *)where classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  更新操作
 *
 *  @param model       要更新的模型
 *  @param classInfo   类的包装对象
 *  @param resultBlock 结果
 */
+ (void)wd_updateWithModel:(NSObject *)model classInfo:(WDClassInfo *)classInfo resultBlock:(void (^)(BOOL success))resultBlock;

/**
 *  删除表
 *
 *  @param tableName 表名
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)wd_clearTable:(NSString *)tableName;
@end

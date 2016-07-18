//
//  WDJsonKitManager.h
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKitCache.h"

@class WDClassInfo,WDJsonKitCache,WDDBOperation,WDTransformOperation;

@interface WDJsonKitManager : NSObject
/**
 *  缓存对象
 */
@property (nonatomic, strong, readonly) WDJsonKitCache *cache;
/**
 *  数据库操作的对象
 */
@property (nonatomic, strong, readonly) WDDBOperation *dbOperation;
/**
 *  转换对象
 */
@property (nonatomic, strong, readonly) WDTransformOperation *transformOperation;
/**
 *  单例方法
 *
 *  @return 对象本身
 */
+ (instancetype)sharedManager;
/**
 *  通过字典来创建一个模型
 *
 *  @param json 字典
 *  @param clazz 类
 *  @return 返回一个模型对象
 */
- (id)modelWithJson:(id)json clazz:(Class)clazz;
/**
 *  通过字典数据来创建一个模型数组
 *
 *  @param json 字典数组，里面可以装字典，json,NSData
 *  @param clazz 类
 *  @return 返回一个模型数组
 */
- (NSArray *)modelArrayWithJsonArray:(id)json clazz:(Class)clazz;
/**
 *  通过模型来创建一个字典
 *  @param model 模型
 *  @return 返回一个字典
 */
- (NSDictionary *)jsonWithModel:(id)model;
/**
 *  通过模型数组来创建一个字典数组
 *
 *  @param model 模型数组
 *
 *  @return 返回一个创建好的字典数组
 */
- (NSArray *)jsonArrayWithModelArray:(id)model;
/**
 *  归档
 *
 *  @param aCoder acoder
 *  @param object 要归档的对象
 */
- (void)encodeWithCoder:(NSCoder *)aCoder object:(id)object;
/**
 *  解档
 *
 *  @param aDecoder adecoder
 *  @param object 要解档的对象
 */
- (void)decodeWithCoder:(NSCoder *)aDecoder object:(id)object;
/**
 *  插入一条记录，只是执行插入操作
 *
 *  @param model       要插入的模型
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)insertWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock;
/**
 *  批量插入
 *
 *  @param models      要插入的模型数组
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)insertWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock;
/**
 *  插入一条记录，如果记录存在，执行更新操作
 *
 *  @param model       要插入的模型
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)saveWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock;
/**
 *  批量插入
 *
 *  @param models      要插入的模型数组
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)saveWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  条件查询，注意，当查询条件中有字符串字段的时候，需要加上 ''
 *
 *  @param where       查询条件
 *  @param groupBy     分组条件
 *  @param orderBy     排序
 *  @param limit       分页
 @param async       是否开启线程
 *  @param resultBlock 查询结果
 */
- (void)queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  条件查询
 *
 *  @param param       查询条件的字典
 *  @param groupBy     分组条件
 *  @param orderBy     排序
 *  @param limit       分页
 *  @param async       是否开启线程
 *  @param resultBlock 查询结果
 */
- (void)queryWithParam:(NSDictionary *)param groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  条件查询
 *
 *  @param identify    通过标识进行查询
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)queryWithRowIdentify:(id)identify clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  删除操作
 *
 *  @param where 查询条件
 *  @param async 是否开启线程
 *  @param resultBlock 结果
 */
- (void)deleteWithWhere:(NSString *)where clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  删除操作
 *
 *  @param param       删除条件的字典
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)deleteWithParam:(NSDictionary *)param clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock;
/**
 *  更新操作
 *
 *  @param model       更新的模型
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)updateWithModel:(NSObject *)model clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  批量更新
 *
 *  @param models      更新的模型数组
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)updateWithModels:(NSArray *)models clazz:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  清空表
 *  @param clazz       类
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
- (void)clearTable:(Class)clazz async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;

@end

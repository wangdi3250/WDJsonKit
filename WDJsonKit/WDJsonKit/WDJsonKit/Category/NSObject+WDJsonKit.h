//
//  NSObject+WDJsonKit.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKitProtocol.h"

@interface NSObject (WDJsonKit)<WDJsonKitProtocol>
/**
 *  关联一个属性，内部使用
 */
@property (nonatomic, assign) NSInteger wd_aID;
/**
 *  通过字典来创建一个模型
 *
 *  @param json 字典数据，可以是dict，json，NSData
 *
 *  @return 返回一个创建好的模型
 */
+ (instancetype)wd_modelWithJson:(id)json;
/**
 *  通过字典数组来创建一个模型数组
 *
 *  @param json 字典数组，里面可以装字典，json,NSData
 *
 *  @return 返回一个创建好的模型数组
 */
+ (NSArray *)wd_modelArrayWithJsonArray:(id)json;
/**
 *  模型转字典
 *
 *  @return 返回一个字典
 */
- (NSDictionary *)wd_jsonWithModel;
/**
 *  通过模型数组来创建一个字典数组
 *
 *  @param model 模型数组
 *
 *  @return 返回一个创建好的字典数组
 */
+ (NSArray *)wd_jsonArrayWithModelArray:(id)model;

/**
 *  归档
 *
 *  @param aCoder acoder
 */
- (void)wd_encodeWithCoder:(NSCoder *)aCoder;
/**
 *  解档
 *
 *  @param aDecoder adecoder
 *
 *  @return 对象本身
 */
- (void)wd_decodeWithCoder:(NSCoder *)aDecoder;
/**
 *  插入一条记录，如果记录存在，执行更新操作，不开启线程
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)wd_save;
/**
 *  插入一条记录，只是执行插入操作，不开启线程
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)wd_insert;
/**
 *  插入一条记录，如果记录存在，执行更新操作
 *
 *  @param model       要插入的模型
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_saveWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  批量插入
 *
 *  @param models      要插入的模型数组
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_saveWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  插入一条记录，只是执行插入操作
 *
 *  @param model       要插入的模型
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_insertWithModel:(id)model async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  批量插入
 *
 *  @param models      要插入的模型数组
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_insertWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  查询所有记录，不开启线程
 *
 *  @return 查询结果
 */
+ (NSArray *)wd_query;
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
+ (void)wd_queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock;
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
+ (void)wd_queryWithParam:(NSDictionary *)param groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  条件查询
 *
 *  @param identify    通过标识进行查询
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_queryWithRowIdentify:(id)identify async:(BOOL)async resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  删除所有数据，不开启线程
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)wd_delete;
/**
 *  删除操作
 *
 *  @param where 查询条件
 *  @param async 是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_deleteWithWhere:(NSString *)where async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  删除操作
 *
 *  @param param       删除条件的字典
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_deleteWithParam:(NSDictionary *)param async:(BOOL)async resultBlock:(void (^)(BOOL))resultBlock;
/**
 *  更新操作，不开启线程
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)wd_update;
/**
 *  更新操作
 *
 *  @param model       更新的模型
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_updateWithModel:(NSObject *)model async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  批量更新
 *
 *  @param models      更新的模型数组
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_updateWithModels:(NSArray *)models async:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  清空表
 *
 *  @param async       是否开启线程
 *  @param resultBlock 结果
 */
+ (void)wd_clearTable:(BOOL)async resultBlock:(void (^)(BOOL success))resultBlock;

@end

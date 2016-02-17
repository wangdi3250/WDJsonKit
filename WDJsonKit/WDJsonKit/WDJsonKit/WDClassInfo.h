//
//  WDClassInfo.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDClassInfo : NSObject
/**
 *  类
 */
@property (nonatomic, assign) Class clazz;
/**
 *  父类
 */
@property (nonatomic, assign) Class superClazz;
/**
 *  父类的信息
 */
@property (nonatomic, assign) WDClassInfo *superClassInfo;
/**
 * 类名
 */
@property (nonatomic, copy) NSString *name;
/**
 *  类中属性的缓存数组，里面装着WDPropertyInfo对象
 */
@property (nonatomic, strong) NSMutableArray *propertyCache;
/**
 *  类的实例对象
 */
@property (nonatomic, strong) id object;
/**
 *  类中属性的缓存数组，里面装着WDPropertyInfo对象，操作DB的时候使用
 */
@property (nonatomic, strong) NSMutableArray *sqlPropertyCache;
/**
 *  数据库中表名
 */
@property (nonatomic, copy) NSString *tableName;
/**
 *  如果是子model，所属的父model对应的表名，框架内部使用， 外部不要修改
 */
@property (nonatomic, copy) NSString *aModel;
/**
 *  所在类的ID
 */
@property (nonatomic, assign) NSInteger wd_aID;
/**
 *  数据库表中一条记录的标识所对应的模型字段
 */
@property (nonatomic, copy) NSString *rowIdentifyPropertyName;
@property (nonatomic, copy) NSString *rowIdentityColumnName;
/**
 *  提供给外部从缓存中获取WDClassInfo的接口
 *
 *  @param clazz 要获取的类类型，会用来作为字典的key
 *
 *  @return 返回一个WDClassInfo对象
 */
+ (instancetype)wd_classInfoFromCache:(Class)clazz;
/**
 *  转换成NSNUmber类型
 *
 *  @param value 其他类型
 *
 *  @return NSNumber类型
 */
+ (NSNumber *)wd_createNumberWithObject:(id)value;
/**
 *  提供给外部从缓存中获取WDClassInfo的接口，DB操作时候使用
 *
 *  @param clazz 要获取的类类型，会用来作为字典的key
 *
 *  @return 返回一个WDClassInfo对象
 */
+ (instancetype)wd_sqlClassInfoFromCache:(Class)clazz;
/**
 *  通过字典来创建一个模型
 *
 *  @param json 字典
 *
 *  @return 返回一个模型对象
 */
- (instancetype)wd_modelWithJson:(id)json;
/**
 *  通过字典数据来创建一个模型数组
 *
 *  @param json 字典数组，里面可以装字典，json,NSData
 *
 *  @return 返回一个模型数组
 */
- (NSArray *)wd_modelArrayWithJsonArray:(id)json;
/**
 *  通过模型来创建一个字典
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
- (NSArray *)wd_jsonArrayWithModelArray:(id)model;

/**
 *  类是否来至Foundation
 *
 *  @param clazz 类
 *
 *  @return YES属于Foundation No 属于Foundation
 */
+ (BOOL)wd_classFromFoundation:(Class)clazz;
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
 */
- (void)wd_decodeWithCoder:(NSCoder *)aDecoder;
/**
 *  插入一条记录，如果记录存在，执行更新操作
 *  @param resultBlock 是否成功
 */
- (void)wd_saveWithResultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  插入一条记录，只是执行插入操作
 *
 *  @param resultBlock 是否成功
 */
- (void)wd_insertWithResultBlock:(void(^)(BOOL success))resultBlock;
/**
 *  条件查询
 *
 *  @param where       查询条件
 *  @param groupBy     分组条件
 *  @param orderBy     排序
 *  @param limit       分页
 *  @param resultBlock 查询结果
 */
- (void)wd_queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit resultBlock:(void (^)(NSArray *result))resultBlock;
/**
 *  删除操作
 *
 *  @param where 查询条件
 *  @param resultBlock 结果
 */
- (void)wd_deleteWithWhere:(NSString *)where resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  更新操作
 *  @param model       更新的模型
 *  @param resultBlock 结果
 */
- (void)wd_updateWithModel:(NSObject *)model resultBlock:(void (^)(BOOL success))resultBlock;
/**
 *  删除表
 *
 *  @param tableName 表名
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)wd_clearTable:(NSString *)tableName;

@end

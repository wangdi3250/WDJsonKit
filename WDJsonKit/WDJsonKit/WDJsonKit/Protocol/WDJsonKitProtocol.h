//
//  WDJsonKitProtocol.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDPropertyInfo;
@protocol WDJsonKitProtocol <NSObject>

@optional
/**
 *  模型中的key和字典中的key的映射关系
 *
 *  @return 映射关系的字典
 */
+ (NSDictionary *)wd_replaceKeysFromOriginKeys;
/**
 *  数组属性中的类类型
 *
 *  @return 数组中的类类型的字典
 */
+ (NSDictionary *)wd_classInArray;
/**
 *  过滤字典中的值
 *
 *  @param oldValue     老的字典中的值
 *  @param propertyInfo 老值所对应的属性信息
 *
 *  @return 新的值
 */
+ (id)wd_newValueFromOldValue:(id)oldValue propertyInfo:(WDPropertyInfo *)propertyInfo;
/**
 *  属性白名单
 *
 *  @return 允许转换的属性的数组
 */
+ (NSArray *)wd_propertyWhiteList;
/**
 *  属性黑名单
 *
 *  @return 不允许转换的属性的数组
 */
+ (NSArray *)wd_propertyBlackList;
/**
 *  归档属性白名单
 *
 *  @return 允许归档的属性数组
 */
+ (NSArray *)wd_encodingPropertyWhiteList;
/**
 *  归档属性黑名单
 *
 *  @return 不运行归档的属性数组
 */
+ (NSArray *)wd_encodingPropertyBlackList;
/**
 *  数据库中表的名字
 *
 *  @return 表名
 */
+ (NSString *)wd_sqlTableName;
/**
 *  模型中的key和数据库表中的字段的映射关系
 *
 *  @return 映射关系的字典
 */
+ (NSDictionary *)wd_sqlReplaceKeysFromOriginKeys;
/**
 *  数组属性中的类类型，当操作数据库的时候，实现这个方法
 *
 *  @return 数组中的类类型的字典
 */
+ (NSDictionary *)wd_sqlClassInArray;
/**
 *  属性白名单
 *
 *  @return 允许转换的属性的数组，当操作数据库的时候，实现这个方法
 */
+ (NSArray *)wd_sqlPropertyWhiteList;
/**
 *  属性黑名单
 *
 *  @return 不允许转换的属性的数组，当操作数据库的时候，实现这个方法
 */
+ (NSArray *)wd_sqlPropertyBlackList;
/**
 *  数据库表中一条记录的标识所对应的模型字段
 *
 *  @return 字段名字
 */
+ (NSString *)wd_sqlRowIdentifyPropertyName;

@end

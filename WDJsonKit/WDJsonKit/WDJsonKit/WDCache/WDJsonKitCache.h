//
//  WDJsonKitCache.h
//  WDJsonKit
//
//  Created by 王迪 on 16/7/10.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDClassInfo;

@interface WDJsonKitCache : NSObject
/**
 *  单例方法
 *
 *  @return 对象本身
 */
+ (instancetype)sharedCache;
/**
 *  提供给外部从缓存中获取WDClassInfo的接口
 *
 *  @param clazz 要获取的类类型，会用来作为字典的key
 *
 *  @return 返回一个WDClassInfo对象
 */
- (WDClassInfo *)classInfoFromCache:(Class)clazz;

/**
 *  从缓存字典中取WDClassInfo对象
 *
 *  @param clazz 要取的类
 *
 *  @return WDClassInfo 对象
 */
- (WDClassInfo *)sqlClassInfoFromCache:(Class)clazz;
/**
 *  提供给外部从缓存中获取WDClassInfo的接口，归档操作的时候用
 *
 *  @param clazz 要获取的类类型，会用来作为字典的key
 *
 *  @return 返回一个WDClassInfo对象
 */
- (WDClassInfo *)encodingClassInfoFromCache:(Class)clazz;
/**
 *  缓存数据库表
 *
 *  @param tableName 表名字
 */
- (void)saveTableName:(NSString *)tableName;
/**
 *  删除表
 *
 *  @param tableName 表名字
 */
- (void)removeTableName:(NSString *)tableName;
/**
 *  数据库表是否存在
 *
 *  @param tableName 表名字
 *
 *  @return 是否存在数据库表
 */
- (BOOL)containsTableName:(NSString *)tableName;

@end

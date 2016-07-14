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
 *  从缓存字典中取WDClassInfo对象
 *
 *  @param clazz 要取的类
 *
 *  @return WDClassInfo 对象
 */
- (WDClassInfo *)classInfoFromCache:(Class)clazz;
/**
 *  将WDClassInfo对象存到缓存字典中
 *
 *  @param classInfo WDClassInfo对象
 *  @param clazz     待缓存的类
 */
- (void)saveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz;
/**
 *  从缓存字典中取WDClassInfo对象
 *
 *  @param clazz 要取的类
 *
 *  @return WDClassInfo 对象
 */
- (WDClassInfo *)sqlClassInfoFromCache:(Class)clazz;
/**
 *  将WDClassInfo对象存到缓存字典中
 *
 *  @param classInfo WDClassInfo对象
 *  @param clazz     待缓存的类
 */
- (void)sqlSaveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz;
/**
 *  从缓存字典中取WDClassInfo对象
 *
 *  @param clazz 要取的类
 *
 *  @return WDClassInfo 对象
 */
- (WDClassInfo *)encodingClassInfoFromCache:(Class)clazz;
/**
 *  将WDClassInfo对象存到缓存字典中
 *
 *  @param classInfo WDClassInfo对象
 *  @param clazz     待缓存的类
 */
- (void)encodingSaveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz;
/**
 *  缓存数据库表
 *
 *  @param tableName 表名字
 */
- (void)saveTableName:(NSString *)tableName;
/**
 *  数据库表是否存在
 *
 *  @param tableName 表名字
 *
 *  @return 是否存在数据库表
 */
- (BOOL)containsTableName:(NSString *)tableName;

@end

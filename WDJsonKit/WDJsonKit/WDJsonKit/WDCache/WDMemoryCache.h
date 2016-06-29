//
//  WDMemoryCache.h
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDMemoryCache : NSObject
/**
 *  缓存数量限制，默认是无限大，没限制
 */
@property (nonatomic, assign) NSUInteger countLimit;
/**
 *  缓存大小的限制，默认是无限大，没限制
 */
@property (nonatomic, assign) NSUInteger sizeLimit;
/**
 *  缓存的时间的限制，默认是无限大，没限制
 */
@property (nonatomic, assign) NSUInteger ageLimit;
/**
 *  自动检测的时间，默认是60s
 */
@property (nonatomic, assign) NSTimeInterval autoTrimInterval;
/**
 *  当收到内存警告的时候是否要清空内存中的缓存
 */
@property (nonatomic, assign) BOOL shouldRemoveAllObjectsWhenMemoryWarning;
/**
 *  存储对象，在当前线程中执行，不会开启新的线程
 *
 *  @param object 对象
 *  @param key    对象的key
 */
- (void)setObject:(id)object forKey:(id)key;
/**
 *  存储对象，在当前线程中执行，不会开启新的线程
 *
 *  @param object 对象
 *  @param key    对象的key
 *  @param cost   对象的大小
 */
- (void)setObject:(id)object forKey:(id)key cost:(NSUInteger)cost;
/**
 *  获取缓存对象，在当前线程中执行，不会开启线程
 *
 *  @param key 缓存对象的key
 *
 *  @return 对象
 */
- (id)objectForKey:(id)key;
/**
 *  删除缓存对象，在当前线程中执行，不会开启线程
 *
 *  @param key 对象的key
 */
- (void)removeObjectForKey:(id)key;
/**
 *  判断缓存中是否包含key所对应的对象，在当前线程中执行，不会开启新的线程
 *
 *  @param key 对象的key
 */
- (BOOL)containsObjectForKey:(id)key;
/**
 *  清空所有缓存，在当前线程中执行，不会开启线程
 */
- (void)removeAllObjects;

@end

//
//  WDCache.h
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDMemoryCache.h"
#import "WDDiskCache.h"

@interface WDCache : NSObject
/**
 *  内存缓存对象
 */
@property (nonatomic, strong, readonly) WDMemoryCache *memoryCache;
/**
 *  磁盘缓存对象
 */
@property (nonatomic, strong, readonly) WDDiskCache *diskCache;
/**
 *  初始化方法
 *
 *  @param name 名字，默认的路径是存放在cache路径中
 *
 *  @return 对象
 */
- (instancetype)initWithName:(NSString *)name;
/**
 *  初始化方法
 *
 *  @param path 路径
 *
 *  @return 对象
 */
- (instancetype)initWithPath:(NSString *)path;
/**
 *  存储对象，在当前线程中执行，不会开启新的线程
 *
 *  @param object 对象
 *  @param key    对象的key
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
/**
 *  存储对象，会开启新的线程
 *
 *  @param object     对象
 *  @param key        对象的key
 *  @param completion 缓存完成的回调block
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key completion:(void (^)())completion;
/**
 *  获取缓存对象，在当前线程中执行，不会开启线程
 *
 *  @param key 缓存对象的key
 *
 *  @return 对象
 */
- (id <NSCoding>)objectForKey:(NSString *)key;
/**
 *  获取缓存对象，会开启新的线程
 *
 *  @param key        对象的key
 *  @param completion 完成的回调block
 */
- (void)objectForKey:(NSString *)key completion:(void (^)(NSString *key,id <NSCoding>object))completion;
/**
 *  删除缓存对象，在当前线程中执行，不会开启线程
 *
 *  @param key 对象的key
 */
- (void)removeObjectForKey:(NSString *)key;
/**
 *  删除缓存对象，会开启新的线程
 *
 *  @param key        对象的key
 *  @param completion 完成的回调block
 */
- (void)removeObjectForKey:(NSString *)key completion:(void (^)())completion;
/**
 *  清空所有缓存，在当前线程中执行，不会开启线程
 */
- (void)removeAllObjects;
/**
 *  清空所有缓存，会开启线程
 *
 *  @param completion 删除完成的回调block
 */
- (void)removeAllObjectsWithCompletion:(void (^)())completion;
/**
 *  判断缓存中是否包含key所对应的对象，在当前线程中执行，不会开启新的线程
 *
 *  @param key 对象的key
 */
- (BOOL)containsObjectForKey:(NSString *)key;
/**
 * 判断缓存中是否包含key所对应的对象，会开启新的线程
 *
 *  @param key        对象的key
 *  @param completion 完成的回调block
 */
- (void)containsObjectForKey:(NSString *)key completion:(void (^)(NSString *key,BOOL containts))completion;

@end

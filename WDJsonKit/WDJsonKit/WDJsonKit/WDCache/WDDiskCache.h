//
//  WDDiskCache.h
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDDiskCache : NSObject
/**
 *  缓存的路径
 */
@property (nonatomic, copy, readonly) NSString *path;
/**
 *  缓存的名字
 */
@property (nonatomic, copy, readonly) NSString *name;
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
 *  归档的回调block
 */
@property (nonatomic, copy) NSData *(^customerArchiveBlock)(id<NSCoding> object);
/**
 *  接档的block
 */
@property (nonatomic, copy) id <NSCoding> (^customrUnArchiveBlock)(NSData *data);
/**
 *  初始化方法
 *
 *  @param path 缓存的路径
 *
 *  @return 对象
 */
- (instancetype)initWithPath:(NSString *)path;
/**
 *  调整缓存数量到指定的数量
 *
 *  @param count 指定的数量
 */
- (void)trimToCount:(NSUInteger)count;
/**
 *  调整缓存大小到指定的大小
 *
 *  @param size 指定的大小
 */
- (void)trimToSize:(NSUInteger)size;
/**
 *  删除过期的缓存
 *
 *  @param age 缓存的时间
 */
- (void)trimToAge:(NSTimeInterval)age;
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

//
//  WDCacheManager.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class WDClassInfo;
@interface WDCacheManager : NSObject
/**
 *  从缓存字典中取WDClassInfo对象
 *
 *  @param clazz 要取的类
 *
 *  @return WDClassInfo 对象
 */
+ (WDClassInfo *)wd_classInfoFromCache:(Class)clazz;
/**
 *  将WDClassInfo对象存到缓存字典中
 *
 *  @param classInfo WDClassInfo对象
 *  @param clazz     待缓存的类
 */
+ (void)wd_saveClassInfoToCache:(WDClassInfo *)classInfo class:(Class)clazz;
/**
 *  缓存model数组
 *
 *  @param result    model数组
 *  @param classInfo 类的包装对象
 */
+ (void)wd_saveQueryResultToCache:(NSArray *)result classInfo:(WDClassInfo *)classInfo;
/**
 *  缓存单个model
 *
 *  @param model     model
 *  @param classInfo 类的包装对象
 */
+ (void)wd_saveQueryModelToCache:(id)model classInfo:(WDClassInfo *)classInfo;
/**
 *  根据模型的标识是缓存中查模型
 *
 *  @param rowIdentify 模型的标识
 *  @param classInfo   类的包装对象
 *
 *  @return 查询结果
 */
+ (NSArray *)wd_modelWithRowIdentify:(id)rowIdentify classInfo:(WDClassInfo *)classInfo;
/**
 *  从缓存中删除模型
 *
 *  @param rowIdentify 模型的标识
 *  @param classInfo   类的包装对象
 */
+ (void)wd_removeModelWithRowIdentfy:(id)rowIdentify classInfo:(WDClassInfo *)classInfo;
@end

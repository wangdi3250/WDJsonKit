//
//  WDTransformOperation.h
//  WDJsonKit
//
//  Created by 王迪 on 16/7/18.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDClassInfo;

@interface WDTransformOperation : NSObject
/**
 *  单例方法
 *
 *  @return 对象本身
 */
+ (instancetype)sharedOperation;
/**
 *  通过字典来创建一个模型
 *
 *  @param json      字典
 *  @param classInfo 类的包装对象
 *
 *  @return 创建好的模型
 */
- (id)modelWithJson:(id)json classInfo:(WDClassInfo *)classInfo;
/**
 *  通过字典数据来创建一个模型数组
 *
 *  @param json      字典数组
 *  @param classInfo 类的包装对象
 *
 *  @return 模型数组
 */
- (NSArray *)modelArrayWithJsonArray:(id)json classInfo:(WDClassInfo *)classInfo;
/**
 *  通过模型来创建一个字典
 *
 *  @param classInfo 类的包装对象
 *
 *  @return 创建好的字典
 */
- (NSDictionary *)jsonWithModel:(WDClassInfo *)classInfo;
/**
 *  通过模型数组来创建一个字典数组
 *
 *  @param model 模型数组
 *
 *  @return 字典数组
 */
- (NSArray *)jsonArrayWithModelArray:(NSArray *)model;
/**
 *  归档
 *
 *  @param aCoder    归档类
 *  @param classInfo 类的包装对象
 */
- (void)encodeWithCoder:(NSCoder *)aCoder classInfo:(WDClassInfo *)classInfo;
/**
 *  解档
 *
 *  @param aDecoder  解档类
 *  @param classInfo 类的包装对象
 */
- (void)decodeWithCoder:(NSCoder *)aDecoder classInfo:(WDClassInfo *)classInfo;

@end

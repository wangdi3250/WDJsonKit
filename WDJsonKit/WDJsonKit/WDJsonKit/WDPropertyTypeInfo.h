//
//  WDPropertyTypeInfo.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKitConst.h"
#import <objc/runtime.h>

@interface WDPropertyTypeInfo : NSObject

/**
 类型标识符
 */
@property (nonatomic, copy) NSString *typeCode;
/**
 是否为基本数字类型：int、float等
 */
@property (nonatomic, readonly, getter = isNumberType) BOOL numberType;
/**
 *  如果是基本数字类型，是否为整形
 */
@property (nonatomic, readonly, getter = isIntegerType) BOOL integerType;

/**
 对象类型（如果是基本数据类型，此值为nil）
 */
@property (nonatomic, assign, readonly) Class typeClass;
/**
 类型是否来自于Foundation框架，比如NSString、NSArray
 */
@property (nonatomic, readonly, getter = isFromFoundation) BOOL fromFoundation;
/**
 *  类型的枚举
 */
@property (nonatomic, assign,readonly) WDEncodingType encodingType;
/**
 *  初始化方法
 *
 *  @param typeCode 类型标识符
 *
 *  @return 创建好的WDPropertyTypeInfo对象
 */
+ (instancetype)wd_propertyTypeWithTypeCode:(NSString *)typeCode;

@end

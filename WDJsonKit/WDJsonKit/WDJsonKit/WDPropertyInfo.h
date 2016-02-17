//
//  WDPropertyInfo.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "WDJsonKitConst.h"

@class WDPropertyTypeInfo;
@interface WDPropertyInfo : NSObject
/**
 *  属性
 */
@property (nonatomic, assign) objc_property_t property_t;
/**
 *  属性名字
 */
@property (nonatomic, copy, readonly) NSString *name;
/**
 *  属性的值
 */
@property (nonatomic, strong) id value;
/**
 *  属性类型
 */
@property (nonatomic, strong, readonly) WDPropertyTypeInfo *type;
/**
 *  映射到数据库表中的类型的完整描述
 */
@property (nonatomic, copy, readonly) NSString *sqlColumnTypeDesc;
/**
 *  属性映射到数据库表中的字段
 */
@property (nonatomic, copy, readonly) NSString *sqlColumnName;
/**
 *  保存着模型的这个属性对应着字典中的key，可以是多级映射
 */
@property (nonatomic, strong) NSMutableArray *mappingKeyPath;
/**
 *  数组当中的类型，可能为空
 */
@property (nonatomic, assign, readonly) Class arrayClazz;
/**
 类型是否来自于Foundation框架，比如NSString、NSArray
 */
@property (nonatomic, readonly, getter = isArrayClazzFromFoundation) BOOL arrayClazzFromFoundation;
@property (nonatomic, readonly, getter = isSqlArrayClazzFromFoundation) BOOL sqlArrayClazzFromFoundation;
/**
 *  setter方法
 */
@property (nonatomic, assign,readonly) SEL setter;
/**
 *  getter方法
 */
@property (nonatomic, assign, readonly) SEL getter;
/**
 *  赋值的方式，如果属性是readOnly，采用KVC赋值，否则采用runtime的消息机制
 */
@property (nonatomic, assign, readonly) WDAssignmentType assigmnetType;
/**
 *  数组当中的类型，可能为空，当操作数据库时候这个属性才有效
 */
@property (nonatomic, assign, readonly) Class sqlArrayClazz;
/**
 *  初始化方法
 *
 *  @param property_t 属性
 *
 *  @return WDPropertyInfo 对象
 */
+ (instancetype)wd_propertyWithProperty_t:(objc_property_t)property_t;
- (void)wd_setupkeysMappingWithMappingDict:(NSDictionary *)mappingDict;
- (void)wd_setupClassInArrayWithClassInArrayDict:(NSDictionary *)classInArrayDict;
- (void)wd_setupSQLKeysMappingWithSQLMappingDict:(NSDictionary *)sqlMappingDict;
- (void)wd_setupSQLClassInArrayWithSQLClassInArrayDict:(NSDictionary *)sqlClassInArrayDict;

@end

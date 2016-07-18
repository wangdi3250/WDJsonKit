//
//  WDClassInfo.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDClassInfo : NSObject
/**
 *  类
 */
@property (nonatomic, assign) Class clazz;
/**
 *  父类
 */
@property (nonatomic, assign) Class superClazz;
/**
 *  父类的信息
 */
@property (nonatomic, assign) WDClassInfo *superClassInfo;
/**
 * 类名
 */
@property (nonatomic, copy) NSString *name;
/**
 *  类中属性的缓存数组，里面装着WDPropertyInfo对象
 */
@property (nonatomic, strong, readonly) NSMutableArray *propertyCache;
/**
 *  类的实例对象
 */
@property (nonatomic, strong) id object;
/**
 *  类中属性的缓存数组，里面装着WDPropertyInfo对象，操作DB的时候使用
 */
@property (nonatomic, strong, readonly) NSMutableArray *sqlPropertyCache;
/**
 *  类中属性的缓存数组，里面装着WDPropertyInfo对象，归档的时候使用
 */
@property (nonatomic, strong, readonly) NSMutableArray *encodingPropertyCache;
/**
 *  数据库中表名
 */
@property (nonatomic, copy) NSString *tableName;
/**
 *  如果是子model，所属的父model对应的表名，框架内部使用， 外部不要修改
 */
@property (nonatomic, copy) NSString *aModel;
/**
 *  所在类的ID
 */
@property (nonatomic, strong) id wd_aID;
/**
 *  数据库表中一条记录的标识所对应的模型字段
 */
@property (nonatomic, copy) NSString *rowIdentifyPropertyName;
@property (nonatomic, copy) NSString *rowIdentityColumnName;
/**
 *  添加额外的字段
 */
- (void)addExtensionProperty;


@end

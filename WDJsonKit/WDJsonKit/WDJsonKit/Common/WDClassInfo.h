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
@property (nonatomic, assign) NSInteger wd_aID;
/**
 *  数据库表中一条记录的标识所对应的模型字段
 */
@property (nonatomic, copy) NSString *rowIdentifyPropertyName;
@property (nonatomic, copy) NSString *rowIdentityColumnName;
/**
 *  转换成NSNUmber类型
 *
 *  @param value 其他类型
 *
 *  @return NSNumber类型
 */
+ (NSNumber *)createNumberWithObject:(id)value;
/**
 *  通过字典来创建一个模型
 *
 *  @param json 字典
 *
 *  @return 返回一个模型对象
 */
- (instancetype)modelWithJson:(id)json;
/**
 *  通过字典数据来创建一个模型数组
 *
 *  @param json 字典数组，里面可以装字典，json,NSData
 *
 *  @return 返回一个模型数组
 */
- (NSArray *)modelArrayWithJsonArray:(id)json;
/**
 *  通过模型来创建一个字典
 *
 *  @return 返回一个字典
 */
- (NSDictionary *)jsonWithModel;
/**
 *  通过模型数组来创建一个字典数组
 *
 *  @param model 模型数组
 *
 *  @return 返回一个创建好的字典数组
 */
- (NSArray *)jsonArrayWithModelArray:(id)model;

/**
 *  类是否来至Foundation
 *
 *  @param clazz 类
 *
 *  @return YES属于Foundation No 属于Foundation
 */
+ (BOOL)classFromFoundation:(Class)clazz;
/**
 *  归档
 *
 *  @param aCoder acoder
 */
- (void)encodeWithCoder:(NSCoder *)aCoder;
/**
 *  解档
 *
 *  @param aDecoder adecoder
 *
 */
- (void)decodeWithCoder:(NSCoder *)aDecoder;
/**
 *  添加额外的字段
 */
- (void)addExtensionProperty;


@end

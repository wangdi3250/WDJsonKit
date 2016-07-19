//
//  WDJsonKitTool.h
//  WDJsonKit
//
//  Created by 王迪 on 16/7/18.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKitConst.h"

@class WDPropertyInfo;
@interface WDJsonKitTool : NSObject
/**
 *  类是否来至Foundation
 *
 *  @param clazz 类
 *
 *  @return YES属于Foundation No 属于Foundation
 */
+ (BOOL)classFromFoundation:(Class)clazz;
/**
 *  转换成NSNUmber类型
 *
 *  @param value 其他类型
 *
 *  @return NSNumber类型
 */
+ (NSNumber *)createNumberWithObject:(id)value;
+ (void)setupNumberTypeWithModel:(id)model number:(NSNumber *)num propertyInfo:(WDPropertyInfo *)propertyInfo;
+ (NSNumber *)numberTypeWithModel:(id)model propertyInfo:(WDPropertyInfo *)propertyInfo;
+ (id)objectWithJsonString:(NSString *)json;
+ (id)objectWithData:(NSData *)data;
+ (WDEncodingType)encodingGetType:(const char *)typeEncoding;
+ (BOOL)encodingTypeIsNumberType:(WDEncodingType)type;

@end

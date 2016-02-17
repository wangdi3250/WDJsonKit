//
//  WDMappingKey.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/14.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKitConst.h"

@class WDPropertyInfo;

@interface WDMappingKey : NSObject
/**
 *  映射key的类型
 */
@property (nonatomic, copy) NSString *name;
/**
 *  映射key的类型
 */
@property (nonatomic, assign) WDMappingKeyType type;
/**
 *  从字典中取值
 *
 *  @param object 可能是数组，也可能是字典
 *
 *  @return 所对应的值
 */
- (id)wd_valueWithObject:(id)object;

@end

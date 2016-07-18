//
//  WDClassInfo.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDClassInfo.h"
#import <objc/runtime.h>
#import "WDPropertyInfo.h"
#import "WDJsonKitProtocol.h"
#import "WDMappingKey.h"
#import "NSString+WDJsonKit.h"
#import "WDPropertyTypeInfo.h"
#import "WDJsonKitConst.h"
#import <objc/message.h>
#import "WDJsonKitManager.h"
#import "WDJsonKitTool.h"

@implementation WDClassInfo

@synthesize propertyCache = _propertyCache;
@synthesize sqlPropertyCache = _sqlPropertyCache;
@synthesize encodingPropertyCache = _encodingPropertyCache;

#pragma mark -  懒加载
- (NSMutableArray *)propertyCache
{
    if(!_propertyCache) {
        _propertyCache = [NSMutableArray array];
    }
    return _propertyCache;
}
- (NSMutableArray *)sqlPropertyCache
{
    if(!_sqlPropertyCache) {
        _sqlPropertyCache = [NSMutableArray array];
    }
    return _sqlPropertyCache;
}

- (NSMutableArray *)encodingPropertyCache
{
    if(!_encodingPropertyCache) {
        _encodingPropertyCache = [NSMutableArray array];
    }
    return _encodingPropertyCache;
}

- (void)addExtensionProperty
{
    objc_property_t aIDProperty_t = class_getProperty([self class], WDaID.UTF8String);
    WDPropertyInfo *aIDpropertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:aIDProperty_t];
    [aIDpropertyInfo wd_setupSQLKeysMappingWithSQLMappingDict:nil];
    [self.sqlPropertyCache addObject:aIDpropertyInfo];
}

@end

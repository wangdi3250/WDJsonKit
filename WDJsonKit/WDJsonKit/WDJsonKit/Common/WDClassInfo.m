//
//  WDClassInfo.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDClassInfo.h"
#import <objc/runtime.h>
#import "WDJsonKitConst.h"
#import "WDPropertyInfo.h"

@implementation WDClassInfo

@synthesize propertyCache = _propertyCache;
@synthesize sqlPropertyCache = _sqlPropertyCache;
@synthesize encodingPropertyCache = _encodingPropertyCache;

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
    WDPropertyInfo *aIDpropertyInfo = [WDPropertyInfo propertyWithProperty_t:aIDProperty_t];
    [aIDpropertyInfo setupSQLKeysMappingWithSQLMappingDict:nil];
    [self.sqlPropertyCache addObject:aIDpropertyInfo];
}

@end

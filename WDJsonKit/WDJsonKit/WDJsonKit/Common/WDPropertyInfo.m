//
//  WDPropertyInfo.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDPropertyInfo.h"
#import "WDPropertyTypeInfo.h"
#import "WDMappingKey.h"
#import "NSString+WDJsonKit.h"
#import "WDClassInfo.h"
#import "WDJsonKitTool.h"

@implementation WDPropertyInfo

#pragma mark 懒加载
- (NSMutableArray *)mappingKeyPath
{
    if(_mappingKeyPath == nil) {
        _mappingKeyPath = [NSMutableArray array];
    }
    return _mappingKeyPath;
}

#pragma mark 初始化方法
+ (instancetype)propertyWithProperty_t:(objc_property_t)property_t
{
    WDPropertyInfo *propertyInfo = [[self alloc] init];
    propertyInfo.property_t = property_t;
    return propertyInfo;
}

#pragma mark 重写setter
- (void)setProperty_t:(objc_property_t)property_t
{
    _property_t = property_t;
    _name = @(property_getName(property_t));
    if(!_name.length || [_name isEqualToString:WDDescription] || [_name isEqualToString:WDDebugDescription]) {
        _name = nil;
        return;
    }
    unsigned int outCount = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(property_t, &outCount);
    for(int i = 0;i < outCount;i++) {
        objc_property_attribute_t attr = attrs[i];
        switch (attr.name[0]) {
            case 'T':
            {
                if(attr.value) {
                    _type = [WDPropertyTypeInfo wd_propertyTypeWithTypeCode:@(attr.value)];
                }
            }
            break;
            case 'G':
            {
                if (attr.value) {
                    _getter = NSSelectorFromString(@(attr.value));
                }
            }
            break;
            case 'S':
            {
                if (attr.value) {
                    _setter = NSSelectorFromString(@(attr.value));
                }
            }
            break;
            case 'R':
            {
                _assigmnetType = WDAssignmentTypeKVC;
            }
            break;
        }
    }
    if(attrs) {
        free(attrs);
    }
    if(!_setter) {
        _setter = NSSelectorFromString([_name wd_createSetter]);
    }
    if(!_getter) {
        _getter = NSSelectorFromString(_name);
    }
}

- (void)setupkeysMappingWithMappingDict:(NSDictionary *)mappingDict
{
    if(!self.name.length) return;
    id mappingKey = mappingDict[self.name];
    if(!mappingKey) mappingKey = self.name;
    NSMutableArray *tmpArray = [NSMutableArray array];
    if([mappingKey isKindOfClass:[NSString class]]) {
        [mappingKey wd_enumerateMappingKeyUsingBlock:^(WDMappingKeyType type, NSString *name) {
            WDMappingKey *mappingKey = [[WDMappingKey alloc] init];
            mappingKey.type = type;
            mappingKey.name = name;
            [tmpArray addObject:mappingKey];
        }];
        [self.mappingKeyPath addObject:tmpArray];
    } else if([mappingKey isKindOfClass:[NSArray class]]) {
        for(NSString *key in mappingKey) {
            if(![key isKindOfClass:[NSString class]]) continue;
            [tmpArray removeAllObjects];
            [key wd_enumerateMappingKeyUsingBlock:^(WDMappingKeyType type, NSString *name) {
                WDMappingKey *mappingKey = [[WDMappingKey alloc] init];
                mappingKey.type = type;
                mappingKey.name = name;
                [tmpArray addObject:mappingKey];
            }];
            [self.mappingKeyPath addObject:tmpArray];
        }
    }
}

- (void)setupClassInArrayWithClassInArrayDict:(NSDictionary *)classInArrayDict
{
    if(!self.name.length) return;
    id clazz = classInArrayDict[self.name];
    if(!clazz) return;
    if([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    _arrayClazz = clazz;
    _arrayClazzFromFoundation = [WDJsonKitTool classFromFoundation:_arrayClazz];
}

- (void)setupSQLKeysMappingWithSQLMappingDict:(NSDictionary *)sqlMappingDict
{
    
     NSDictionary *map = @{
                        WDINTEGER_TYPE: @[WDNSInteger,WDNSUInteger,WDEnum_int,WDBOOL,WDNSNumber],
                        WDTEXT_TYPE : @[WDNSString,WDNSMutableString,WDNSURL,WDNSArray,WDNSMutableArray,WDNSDate,WDNSObject],
                        WDREAL_TYPE : @[WDCGFloat],
                        WDBLOB_TYPE : @[WDNSData,WDNSMutableData,WDNSDictionary,WDNSMutableDictionary]
                        };
    
    if(!self.name.length) return;
    id mappingKey = sqlMappingDict[self.name];
    if(!mappingKey) mappingKey = self.name;
    if([mappingKey isKindOfClass:[NSString class]]) {
        _sqlColumnName = mappingKey;
    }
    if(!self.type.isFromFoundation && self.type.typeClass) {
        if(self.isSqlIgnoreBuildNewTable) {
            _sqlColumnTypeDesc = WDBLOB_TYPE;
        } else {
            _sqlColumnName = nil;
        }
        return;
    }
    if(self.type.typeClass && [self.type.typeClass isSubclassOfClass:[NSArray class]]) {
        if(self.sqlArrayClazz) { //数组里面放的对象
            if(self.isSqlIgnoreBuildNewTable) {
                _sqlColumnTypeDesc = WDBLOB_TYPE;
            } else {
                _sqlColumnName = nil;
            }
        } else { //数组里面放的不是对象
            _sqlColumnTypeDesc = WDBLOB_TYPE;
        }
        return;
    }
    __block NSString *sqlColumnTypeDesc = nil;
    [map enumerateKeysAndObjectsUsingBlock:^(NSString *type, NSArray *codes, BOOL *stop) {
        [codes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL *stop) {
            NSRange range = [code rangeOfString:self.type.typeCode];
            if(range.length) {
                sqlColumnTypeDesc = type;
            }
        }];
    }];
    _sqlColumnTypeDesc = sqlColumnTypeDesc;
    
}

- (void)setupSQLClassInArrayWithSQLClassInArrayDict:(NSDictionary *)sqlClassInArrayDict
{
    if(!self.name.length) return;
    id clazz = sqlClassInArrayDict[self.name];
    if(!clazz) return;
    if([clazz isKindOfClass:[NSString class]]) {
        clazz = NSClassFromString(clazz);
    }
    _sqlArrayClazz = clazz;
     _sqlArrayClazzFromFoundation = [WDJsonKitTool classFromFoundation:_sqlArrayClazz];
}

- (void)setupSQLIgnoreBuildNewTableKeyWithignoreBuildNewTableArray:(NSArray *)ignoreBuildNewTableArray
{
    if(!self.name.length) return;
    for(NSString *key in ignoreBuildNewTableArray) {
        if([self.name isEqualToString:key]) {
            _sqlIgnoreBuildNewTable = YES;
            break;
        }
    }
}

@end


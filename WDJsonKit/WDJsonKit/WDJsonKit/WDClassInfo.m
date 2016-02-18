//
//  WDClassInfo.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/12.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDClassInfo.h"
#import <objc/runtime.h>
#import "WDCacheManager.h"
#import "WDPropertyInfo.h"
#import "WDJsonKitProtocol.h"
#import "WDMappingKey.h"
#import "NSString+WDJsonKit.h"
#import "WDPropertyTypeInfo.h"
#import "WDJsonKitConst.h"
#import "WDDBManager.h"
#import <objc/message.h>

@implementation WDClassInfo
static NSSet *_set;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _set = [NSSet setWithObjects: [NSURL class],
                [NSDate class],
                [NSValue class],
                [NSData class],
                [NSError class],
                [NSArray class],
                [NSDictionary class],
                [NSString class],
                [NSNumber class],
                [NSAttributedString class], nil];
    });
}

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

- (NSMutableArray *)encodingProperCache
{
    if(!_encodingProperCache) {
        _encodingProperCache = [NSMutableArray array];
    }
    return _encodingProperCache;
}

#pragma mark - 从缓存取数据
+ (instancetype)wd_classInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = [WDCacheManager wd_classInfoFromCache:clazz];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self wd_classInfoFromCache:superClazz];
        if(classInfo.superClassInfo.propertyCache.count) {
            [classInfo.propertyCache addObjectsFromArray:classInfo.superClassInfo.propertyCache];
        }
        classInfo.name = @(class_getName(clazz));
        classInfo.clazz = clazz;
        classInfo.superClazz = superClazz;
        unsigned int outCount = 0;
        NSDictionary *mappingDict = nil;
        if([clazz respondsToSelector:@selector(wd_replaceKeysFromOriginKeys)]) {
            mappingDict = [clazz wd_replaceKeysFromOriginKeys];
        }
        NSDictionary *classInArrayDict = nil;
        if([clazz respondsToSelector:@selector(wd_classInArray)]) {
            classInArrayDict = [clazz wd_classInArray];
        }
        NSArray *propertyWhiteList = nil;
        if([clazz respondsToSelector:@selector(wd_propertyWhiteList)]) {
            propertyWhiteList = [clazz wd_propertyWhiteList];
        }
        NSArray *propertyBlackList = nil;
        if([clazz respondsToSelector:@selector(wd_propertyBlackList)]) {
            propertyBlackList = [clazz wd_propertyBlackList];
        }
        
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:property];
            if(!propertyWhiteList.count && !propertyBlackList.count) {
                [classInfo.propertyCache addObject:propertyInfo];
            } else if((propertyWhiteList.count && [propertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.propertyCache addObject:propertyInfo];
            } else if(propertyBlackList.count && ![propertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.propertyCache addObject:propertyInfo];
            }
            [propertyInfo wd_setupkeysMappingWithMappingDict:mappingDict];
            [propertyInfo wd_setupClassInArrayWithClassInArrayDict:classInArrayDict];
        }
        if(propertys) {
            free(propertys);
        }
        [WDCacheManager wd_saveClassInfoToCache:classInfo class:clazz];
    }
    return classInfo;
}

+ (instancetype)wd_encodingClassInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = [WDCacheManager wd_classInfoFromCache:clazz];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self wd_encodingClassInfoFromCache:superClazz];
        if(classInfo.superClassInfo.encodingProperCache.count) {
            [classInfo.propertyCache addObjectsFromArray:classInfo.superClassInfo.encodingProperCache];
        }
        classInfo.name = @(class_getName(clazz));
        classInfo.clazz = clazz;
        classInfo.superClazz = superClazz;
        unsigned int outCount = 0;
        NSArray *encodingPropertyWhiteList = nil;
        if([clazz respondsToSelector:@selector(wd_encodingPropertyWhiteList)]) {
            encodingPropertyWhiteList = [clazz wd_encodingPropertyWhiteList];
        }
        NSArray *encodingPropertyBlackList = nil;
        if([clazz respondsToSelector:@selector(wd_encodingPropertyBlackList)]) {
            encodingPropertyBlackList = [clazz wd_encodingPropertyBlackList];
        }
        
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:property];
            if(!encodingPropertyWhiteList.count && !encodingPropertyBlackList.count) {
                [classInfo.encodingProperCache addObject:propertyInfo];
            } else if((encodingPropertyWhiteList.count && [encodingPropertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.encodingProperCache addObject:propertyInfo];
            } else if(encodingPropertyBlackList.count && ![encodingPropertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.encodingProperCache addObject:propertyInfo];
            }
        }
        if(propertys) {
            free(propertys);
        }
        [WDCacheManager wd_saveClassInfoToCache:classInfo class:clazz];
    }
    return classInfo;
}

+ (instancetype)wd_sqlClassInfoFromCache:(Class)clazz
{
    if(clazz == [NSObject class]) return nil;
    WDClassInfo *classInfo = [WDDBManager wd_sqlClassInfoFromCache:clazz];
    if(!classInfo) {
        classInfo = [[WDClassInfo alloc] init];
        Class superClazz = class_getSuperclass(clazz);
        classInfo.superClassInfo = [self wd_sqlClassInfoFromCache:superClazz];
        if(!classInfo.superClassInfo) {
            [classInfo wd_addExtensionProperty];
        }
        if(classInfo.superClassInfo.sqlPropertyCache.count) {
            [classInfo.sqlPropertyCache addObjectsFromArray:classInfo.superClassInfo.sqlPropertyCache];
        }
        classInfo.name = @(class_getName(clazz));
        classInfo.clazz = clazz;
        classInfo.superClazz = superClazz;
        NSString *tableName = nil;
        if([clazz respondsToSelector:@selector(wd_sqlTableName)]) {
            tableName = [clazz wd_sqlTableName];
        }
        classInfo.tableName = tableName ? : NSStringFromClass(classInfo.clazz);
        unsigned int outCount = 0;
        NSDictionary *sqlMappingDict = nil;
        if([clazz respondsToSelector:@selector(wd_sqlReplaceKeysFromOriginKeys)]) {
            sqlMappingDict = [clazz wd_sqlReplaceKeysFromOriginKeys];
        }
        NSDictionary *sqlClassInArrayDict = nil;
        if([clazz respondsToSelector:@selector(wd_sqlClassInArray)]) {
            sqlClassInArrayDict = [clazz wd_sqlClassInArray];
        }
        NSArray *sqlPropertyWhiteList = nil;
        if([clazz respondsToSelector:@selector(wd_sqlPropertyWhiteList)]) {
            sqlPropertyWhiteList = [clazz wd_sqlPropertyWhiteList];
        }
        NSArray *sqlPropertyBlackList = nil;
        if([clazz respondsToSelector:@selector(wd_sqlPropertyBlackList)]) {
            sqlPropertyBlackList = [clazz wd_sqlPropertyBlackList];
        }
        
        NSAssert([clazz respondsToSelector:@selector(wd_sqlRowIdentifyPropertyName)], @"错误：%@ 想要使用数据持久化，必须实现（wd_sqlRowIdentifyPropertyName）方法返回模型的标识字段的名字",classInfo.name);
        classInfo.rowIdentifyPropertyName = [clazz wd_sqlRowIdentifyPropertyName];
        objc_property_t *propertys = class_copyPropertyList(clazz, &outCount);
        for(int i = 0;i < outCount;i++) {
            objc_property_t property = propertys[i];
            WDPropertyInfo *propertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:property];
            if(!sqlPropertyWhiteList.count && !sqlPropertyBlackList.count) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            } else if((sqlPropertyWhiteList.count && [sqlPropertyWhiteList containsObject:propertyInfo.name])) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            } else if(sqlPropertyBlackList.count && ![sqlPropertyBlackList containsObject:propertyInfo.name]) {
                [classInfo.sqlPropertyCache addObject:propertyInfo];
            }
            [propertyInfo wd_setupSQLClassInArrayWithSQLClassInArrayDict:sqlClassInArrayDict];
            [propertyInfo wd_setupSQLKeysMappingWithSQLMappingDict:sqlMappingDict];
            if([propertyInfo.name isEqualToString:classInfo.rowIdentifyPropertyName]) {
                classInfo.rowIdentityColumnName = propertyInfo.sqlColumnName;
            }
        }
        if(propertys) {
            free(propertys);
        }
        NSAssert(classInfo.rowIdentityColumnName && classInfo.rowIdentifyPropertyName, @"错误：rowIdentityColumnName 或者rowIdentifyPropertyName 不能为空，请检查 %@类 是否实现（wd_sqlRowIdentifyPropertyName）方法",classInfo.name);
        [WDDBManager wd_sqlSaveClassInfoToCache:classInfo class:clazz];
    }
    return classInfo;

}

- (instancetype)wd_modelWithJson:(id)json
{
    if(!self.clazz) return nil;
    if(!json) return nil;
    if([json isKindOfClass:[NSString class]]) {
        json = wd_objectWithJsonString(json);
    } else if([json isKindOfClass:[NSData class]]) {
        json = wd_objectWithData(json);
    }
    if(![json isKindOfClass:[NSDictionary class]]) return nil;
    id model = [[self.clazz alloc] init];
    for(WDPropertyInfo *propertyInfo in self.propertyCache) {
        id value = nil;
        for(NSArray *array in propertyInfo.mappingKeyPath) {
            value = json;
            for(WDMappingKey *mappingKey in array) {
                value = [mappingKey wd_valueWithObject:value];
            }
            if(value) break;
        }
        if([self.clazz respondsToSelector:@selector(wd_newValueFromOldValue:propertyInfo:)]) {
            value = [self.clazz wd_newValueFromOldValue:value propertyInfo:propertyInfo];
        }
        if(!value || value == [NSNull null]) continue;
        @try {
            WDPropertyTypeInfo *propertyType = propertyInfo.type;
            Class typeClazz = propertyType.typeClass;
            Class arrayClazz = propertyInfo.arrayClazz;
            if(!propertyType.isFromFoundation && typeClazz) { //先处理对象类型，此时是自定义对象类型
                WDClassInfo *classInfo = [WDClassInfo wd_classInfoFromCache:typeClazz];
                value = [classInfo wd_modelWithJson:value];
            } else if(typeClazz && arrayClazz) { //数组类型
                if([value isKindOfClass:[NSArray class]]) {
                    if(!propertyInfo.isArrayClazzFromFoundation) {
                        WDClassInfo *classInfo = [WDClassInfo wd_classInfoFromCache:arrayClazz];
                        value = [classInfo wd_modelArrayWithJsonArray:value];
                    }
                }
            } else { //处理一些基本数据类型和NSString之间的转换
                if(typeClazz == [NSString class]) {
                    if([value isKindOfClass:[NSNumber class]]) { //NSNumber->NSString
                        value = [value description];
                    } else if([value isKindOfClass:[NSURL class]]) { //NSURL->NSString
                        value = [value absoluteString];
                    }
                } else if([value isKindOfClass:[NSString class]]) {
                    if(typeClazz == [NSURL class]) { //NSString->NSURL
                        value = [(NSString *)value wd_url];
                    } else if(propertyType.isNumberType && propertyInfo.assigmnetType == WDAssignmentTypeMessage) { //NSString->NSNumber
                        NSNumber *num = [WDClassInfo wd_createNumberWithObject:value];
                        wd_setupNumberTypeValue(model, num, propertyInfo);
                        continue;
                    }
                } else if([value isKindOfClass:[NSNumber class]]) {
                    if(propertyType.isNumberType && propertyInfo.assigmnetType == WDAssignmentTypeMessage) {
                        NSNumber *num = (NSNumber *)value;
                        wd_setupNumberTypeValue(model, num, propertyInfo);
                        continue;
                        
                    }
                }
                
            }
            //类型校验
            if(typeClazz && ![value isKindOfClass:typeClazz]) value = nil;
            if(!value) continue;
            if(propertyInfo.assigmnetType == WDAssignmentTypeMessage) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, propertyInfo.setter, (id)value);
            } else {
                [model setValue:value forKey:propertyInfo.name];
            }
        } @catch (NSException *exception) {
            
        }
    }
    
    return model;
}

- (NSArray *)wd_modelArrayWithJsonArray:(id)json
{
    if(!json) return nil;
    if([json isKindOfClass:[NSString class]]) {
        json = wd_objectWithJsonString(json);
    } else if([json isKindOfClass:[NSData class]]) {
        json = wd_objectWithData(json);
    }
    if(![json isKindOfClass:[NSArray class]]) return nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(id object in json) {
        if([object isKindOfClass:[NSArray class]]) {
            NSArray *array = [self wd_modelArrayWithJsonArray:object];
            if(array.count) {
                [tmpArray addObjectsFromArray:array];
            }
        } else if([object isKindOfClass:[NSDictionary class]]) {
            id model = [self wd_modelWithJson:object];
            if(model) {
                [tmpArray addObject:model];
            }
        }
    }
    return tmpArray;
}

- (NSDictionary *)wd_jsonWithModel
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    for(WDPropertyInfo *propertyInfo in self.propertyCache) {
        WDPropertyTypeInfo *propertyType = propertyInfo.type;
        id value = nil;
        if(propertyType.isNumberType) {
            value = wd_numberTypeValue(self.object,propertyInfo);
        } else {
            value = ((id (*)(id, SEL))(void *) objc_msgSend)(self.object,propertyInfo.getter);
        }
        if(!value) continue;
        @try {
            Class typeClazz = propertyType.typeClass;
            if(!propertyType.isFromFoundation && typeClazz) { //对象类型
                WDClassInfo *classInfo = [WDClassInfo wd_classInfoFromCache:typeClazz];
                classInfo.object = value;
                value = [classInfo wd_jsonWithModel];
            } else if([value isKindOfClass:[NSArray class]]) {
                value = [self wd_jsonArrayWithModelArray:value];
            } else if(typeClazz == [NSURL class]) {
                value = [value absoluteString];
            }
            NSArray *mappingKeyArray = [propertyInfo.mappingKeyPath firstObject];
            NSUInteger keyCount = mappingKeyArray.count;
            // 创建字典
            __block id innerContainer = json;
            [mappingKeyArray enumerateObjectsUsingBlock:^(WDMappingKey *mappingKey, NSUInteger idx, BOOL *stop) {
                WDMappingKey *nextMappingKey = nil;
                if (idx != keyCount - 1) {
                    nextMappingKey = mappingKeyArray[idx + 1];
                }
                if (nextMappingKey) { // 不是最后一个key
                    id tempInnerContainer = [mappingKey wd_valueWithObject:innerContainer];
                    if (tempInnerContainer == nil || [tempInnerContainer isKindOfClass:[NSNull class]]) {
                        if (nextMappingKey.type == WDMappingKeyTypeDictionary) {
                            tempInnerContainer = [NSMutableDictionary dictionary];
                        } else {
                            tempInnerContainer = [NSMutableArray array];
                        }
                        if (mappingKey.type == WDMappingKeyTypeDictionary) {
                            innerContainer[mappingKey.name] = tempInnerContainer;
                        } else {
                            innerContainer[mappingKey.name.intValue] = tempInnerContainer;
                        }
                    }
                    if ([tempInnerContainer isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray *tempInnerContainerArray = tempInnerContainer;
                        int index = nextMappingKey.name.intValue;
                        while (tempInnerContainerArray.count < index + 1) {
                            [tempInnerContainerArray addObject:[NSNull null]];
                        }
                    }
                    innerContainer = tempInnerContainer;
                } else { // 最后一个key
                    if (mappingKey.type == WDMappingKeyTypeDictionary) {
                        innerContainer[mappingKey.name] = value;
                    } else {
                        innerContainer[mappingKey.name.intValue] = value;
                    }
                }
            }];
        }@catch (NSException *exception) {
            
        }
    }
    return json;
}

- (NSArray *)wd_jsonArrayWithModelArray:(id)model
{
    if(![model isKindOfClass:[NSArray class]]) return nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(id obj in model) {
        if(![WDClassInfo wd_classFromFoundation:[obj class]]) {
            WDClassInfo *classInfo = [WDClassInfo wd_classInfoFromCache:[obj class]];
            classInfo.object = obj;
            id dict = [classInfo wd_jsonWithModel];
            if(dict) {
                [tmpArray addObject:dict];
            }
            
        } else {
            [tmpArray addObject:obj];
        }
    }
    
    return tmpArray;
}

- (void)wd_encodeWithCoder:(NSCoder *)aCoder
{
    for(WDPropertyInfo *propertyInfo in self.encodingProperCache) {
        WDPropertyTypeInfo *propertyType = propertyInfo.type;
        id value = nil;
        if(propertyType.isNumberType) {
            value = wd_numberTypeValue(self.object,propertyInfo);
        } else {
            value = ((id (*)(id, SEL))(void *) objc_msgSend)(self.object,propertyInfo.getter);
        }
        if(!value || !propertyInfo.name) continue;
        [aCoder encodeObject:value forKey:propertyInfo.name];
    }
}

- (void)wd_decodeWithCoder:(NSCoder *)aDecoder
{
    for(WDPropertyInfo *propertyInfo in self.encodingProperCache) {
        if(!propertyInfo.name) continue;
        WDPropertyTypeInfo *type = propertyInfo.type;
        id value  = [aDecoder decodeObjectForKey:propertyInfo.name];
        if(!value) continue;
        if(type.isNumberType) {
            value = (NSNumber *)value;
            wd_setupNumberTypeValue(self.object, value, propertyInfo);
        } else {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)(self.object, propertyInfo.setter, (id)value);
        }
    }
}

+ (BOOL)wd_classFromFoundation:(Class)clazz
{
    if(clazz == [NSObject class]) return YES;
    __block BOOL FromFoundation = NO;
    [_set enumerateObjectsUsingBlock:^(id  obj, BOOL * stop) {
        if([clazz isSubclassOfClass:obj]) {
            FromFoundation = YES;
            *stop = YES;
        }
    }];
    return FromFoundation;
}

#pragma mark - C函数工具处理方法
+ (NSNumber *)wd_createNumberWithObject:(id)value
{
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull
                };
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

static inline void wd_setupNumberTypeValue(id model,NSNumber *num, WDPropertyInfo *propertyInfo)
{
    if(!model || !propertyInfo || !num) return;
    WDEncodingType type = propertyInfo.type.encodingType;
    switch (type) {
        case WDEncodingTypeBool:
        {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, propertyInfo.setter, num.boolValue);
        }
        break;
        case WDEncodingTypeInt8:
        {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model,propertyInfo.setter, (int8_t)num.charValue);
        }
        break;
        case WDEncodingTypeUInt8:
        {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint8_t)num.unsignedCharValue);
        }
        break;
        case WDEncodingTypeInt16:
        {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int16_t)num.shortValue);
        }
        break;
        case WDEncodingTypeUInt16:
        {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model,propertyInfo.setter, (uint16_t)num.unsignedShortValue);
        }
        break;
        case WDEncodingTypeInt32:
        {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int32_t)num.intValue);
        }
        case WDEncodingTypeUInt32:
        {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint32_t)num.unsignedIntValue);
        }
        break;
        case WDEncodingTypeInt64:
        {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint64_t)num.longLongValue);
            }
        }
        break;
        case WDEncodingTypeUInt64:
        {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint64_t)num.unsignedLongLongValue);
            }
        }
        break;
        case WDEncodingTypeFloat:
        {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, propertyInfo.setter, f);
        }
        break;
        case WDEncodingTypeDouble:
        {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, propertyInfo.setter, d);
        }
        break;
        case WDEncodingTypeLongDouble:
        {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, propertyInfo.setter, (long double)d);
        }
        break;
        default:
        {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, propertyInfo.setter, num);
        }
        break;
    }
}

static inline NSNumber *wd_numberTypeValue(id model,WDPropertyInfo *propertyInfo)
{
    
    WDEncodingType type = propertyInfo.type.encodingType;
    switch (type) {
        case WDEncodingTypeBool:
        {
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeInt8:
        {
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeUInt8:
        {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeInt16:
        {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeUInt16:
        {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeInt32:
        {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeUInt32:
        {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeInt64:
        {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter));
        }
        case WDEncodingTypeFloat:
        {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case WDEncodingTypeDouble:
        {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case WDEncodingTypeLongDouble:
        {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default:
        {
            return ((NSNumber *(*)(id, SEL))(void *) objc_msgSend)((id)model,propertyInfo.getter);
        }
    }
}

static inline id wd_objectWithJsonString(NSString *json)
{
    if(!json) return nil;
    return wd_objectWithData([json dataUsingEncoding:NSUTF8StringEncoding]);
}

static inline id wd_objectWithData(NSData *data)
{
    if(!data) return nil;
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(!error) return jsonDict;
    return nil;
}

#pragma mark - 数据库操作
- (void)wd_saveWithResultBlock:(void (^)(BOOL))resultBlock
{
    [WDDBManager wd_saveWithClassInfo:self resultBlock:^(BOOL success) {
        if(resultBlock) {
            resultBlock(success);
        }
    }];
}

- (void)wd_insertWithResultBlock:(void (^)(BOOL))resultBlock
{
    [WDDBManager wd_insertWithClassInfo:self resultBlock:^(BOOL success) {
    
        if(resultBlock) {
            resultBlock(success);
        }
    }];
}

- (void)wd_queryWithWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit resultBlock:(void (^)(NSArray *))resultBlock
{
    [WDDBManager wd_queryWithWhere:where groupBy:groupBy orderBy:orderBy limit:limit classInfo:self resultBlock:^(NSArray *result) {
        if(resultBlock) {
            resultBlock(result);
        }
    }];
}

- (void)wd_deleteWithWhere:(NSString *)where resultBlock:(void (^)(BOOL))resultBlock
{
    [WDDBManager wd_deleteWithWhere:where classInfo:self resultBlock:^(BOOL success) {
        if(resultBlock) {
            resultBlock(success);
        }
    }];
}

- (void)wd_updateWithModel:(NSObject *)model resultBlock:(void (^)(BOOL))resultBlock
{
    [WDDBManager wd_updateWithModel:model classInfo:self resultBlock:^(BOOL success) {
        if(resultBlock) {
            resultBlock(success);
        }
    }];
}

-(BOOL)wd_clearTable:(NSString *)tableName
{
    return [WDDBManager wd_clearTable:tableName];
}

- (void)wd_addExtensionProperty
{
    objc_property_t aIDProperty_t = class_getProperty([self class], WDaID.UTF8String);
    WDPropertyInfo *aIDpropertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:aIDProperty_t];
    [aIDpropertyInfo wd_setupSQLKeysMappingWithSQLMappingDict:nil];
    [self.sqlPropertyCache addObject:aIDpropertyInfo];
}

@end

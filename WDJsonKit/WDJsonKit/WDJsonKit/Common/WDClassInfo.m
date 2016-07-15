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

@implementation WDClassInfo

@synthesize propertyCache = _propertyCache;
@synthesize sqlPropertyCache = _sqlPropertyCache;
@synthesize encodingPropertyCache = _encodingPropertyCache;

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

- (NSMutableArray *)encodingPropertyCache
{
    if(!_encodingPropertyCache) {
        _encodingPropertyCache = [NSMutableArray array];
    }
    return _encodingPropertyCache;
}

- (instancetype)modelWithJson:(id)json
{
    if(!self.clazz) return nil;
    if(!json) return nil;
    if([json isKindOfClass:[NSString class]]) {
        json = objectWithJsonString(json);
    } else if([json isKindOfClass:[NSData class]]) {
        json = objectWithData(json);
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
            if (typeClazz == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (typeClazz == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (typeClazz == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (typeClazz == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }
            if(!propertyType.isFromFoundation && typeClazz) { //先处理对象类型，此时是自定义对象类型
                WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:typeClazz];
                value = [classInfo modelWithJson:value];
            } else if(typeClazz && arrayClazz) { //数组类型
                if([value isKindOfClass:[NSArray class]]) {
                    if(!propertyInfo.isArrayClazzFromFoundation) {
                        WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:arrayClazz];
                        value = [classInfo modelArrayWithJsonArray:value];
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
                        NSNumber *num = [WDClassInfo createNumberWithObject:value];
                        setupNumberTypeValue(model, num, propertyInfo);
                        continue;
                    }
                } else if([value isKindOfClass:[NSNumber class]]) {
                    if(propertyType.isNumberType && propertyInfo.assigmnetType == WDAssignmentTypeMessage) {
                        NSNumber *num = (NSNumber *)value;
                        setupNumberTypeValue(model, num, propertyInfo);
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

- (NSArray *)modelArrayWithJsonArray:(id)json
{
    if(!json) return nil;
    if([json isKindOfClass:[NSString class]]) {
        json = objectWithJsonString(json);
    } else if([json isKindOfClass:[NSData class]]) {
        json = objectWithData(json);
    }
    if(![json isKindOfClass:[NSArray class]]) return nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(id object in json) {
        if([object isKindOfClass:[NSArray class]]) {
            NSArray *array = [self modelArrayWithJsonArray:object];
            if(array.count) {
                [tmpArray addObjectsFromArray:array];
            }
        } else if([object isKindOfClass:[NSDictionary class]]) {
            id model = [self modelWithJson:object];
            if(model) {
                [tmpArray addObject:model];
            }
        }
    }
    return tmpArray;
}

- (NSDictionary *)jsonWithModel
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    for(WDPropertyInfo *propertyInfo in self.propertyCache) {
        WDPropertyTypeInfo *propertyType = propertyInfo.type;
        id value = nil;
        if(propertyType.isNumberType) {
            value = numberTypeValue(self.object,propertyInfo);
        } else {
            value = ((id (*)(id, SEL))(void *) objc_msgSend)(self.object,propertyInfo.getter);
        }
        if(!value) continue;
        @try {
            Class typeClazz = propertyType.typeClass;
            if(!propertyType.isFromFoundation && typeClazz) { //对象类型
                WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:typeClazz];
                classInfo.object = value;
                value = [classInfo jsonWithModel];
            } else if([value isKindOfClass:[NSArray class]]) {
                value = [self jsonArrayWithModelArray:value];
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

- (NSArray *)jsonArrayWithModelArray:(id)model
{
    if(![model isKindOfClass:[NSArray class]]) return nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(id obj in model) {
        if(![WDClassInfo classFromFoundation:[obj class]]) {
            WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:[obj class]];
            classInfo.object = obj;
            id dict = [classInfo jsonWithModel];
            if(dict) {
                [tmpArray addObject:dict];
            }
            
        } else {
            [tmpArray addObject:obj];
        }
    }
    
    return tmpArray;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for(WDPropertyInfo *propertyInfo in self.encodingPropertyCache) {
        WDPropertyTypeInfo *propertyType = propertyInfo.type;
        id value = nil;
        if(propertyType.isNumberType) {
            value = numberTypeValue(self.object,propertyInfo);
        } else {
            value = ((id (*)(id, SEL))(void *) objc_msgSend)(self.object,propertyInfo.getter);
        }
        if(!value || !propertyInfo.name) continue;
        [aCoder encodeObject:value forKey:propertyInfo.name];
    }
}

- (void)decodeWithCoder:(NSCoder *)aDecoder
{
    for(WDPropertyInfo *propertyInfo in self.encodingPropertyCache) {
        if(!propertyInfo.name) continue;
        WDPropertyTypeInfo *type = propertyInfo.type;
        id value  = [aDecoder decodeObjectForKey:propertyInfo.name];
        if(!value) continue;
        if(type.isNumberType) {
            value = (NSNumber *)value;
            setupNumberTypeValue(self.object, value, propertyInfo);
        } else {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)(self.object, propertyInfo.setter, (id)value);
        }
    }
}

+ (BOOL)classFromFoundation:(Class)clazz
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
+ (NSNumber *)createNumberWithObject:(id)value
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

static inline void setupNumberTypeValue(id model,NSNumber *num, WDPropertyInfo *propertyInfo)
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

static inline NSNumber *numberTypeValue(id model,WDPropertyInfo *propertyInfo)
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

static inline id objectWithJsonString(NSString *json)
{
    if(!json) return nil;
    return objectWithData([json dataUsingEncoding:NSUTF8StringEncoding]);
}

static inline id objectWithData(NSData *data)
{
    if(!data) return nil;
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(!error) return jsonDict;
    return nil;
}

- (void)addExtensionProperty
{
    objc_property_t aIDProperty_t = class_getProperty([self class], WDaID.UTF8String);
    WDPropertyInfo *aIDpropertyInfo = [WDPropertyInfo wd_propertyWithProperty_t:aIDProperty_t];
    [aIDpropertyInfo wd_setupSQLKeysMappingWithSQLMappingDict:nil];
    [self.sqlPropertyCache addObject:aIDpropertyInfo];
}

@end

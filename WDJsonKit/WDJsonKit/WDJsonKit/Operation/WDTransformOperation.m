//
//  WDTransformOperation.m
//  WDJsonKit
//
//  Created by 王迪 on 16/7/18.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDTransformOperation.h"
#import "WDPropertyInfo.h"
#import "WDPropertyTypeInfo.h"
#import "WDClassInfo.h"
#import "WDMappingKey.h"
#import "WDJsonKitProtocol.h"
#import "WDJsonKitManager.h"
#import "NSString+WDJsonKit.h"
#import "WDJsonKitTool.h"
#import <objc/message.h>

@implementation WDTransformOperation

static id _instance;

+ (instancetype)sharedOperation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)modelWithJson:(id)json classInfo:(WDClassInfo *)classInfo
{
    if(!json || !classInfo) return nil;
    if([json isKindOfClass:[NSString class]]) {
        json = [WDJsonKitTool objectWithJsonString:json];
    } else if([json isKindOfClass:[NSData class]]) {
        json = [WDJsonKitTool objectWithData:json];
    }
    if(![json isKindOfClass:[NSDictionary class]]) return nil;
    id model = [[classInfo.clazz alloc] init];
    for(WDPropertyInfo *propertyInfo in classInfo.propertyCache) {
        id value = nil;
        for(NSArray *array in propertyInfo.mappingKeyPath) {
            value = json;
            for(WDMappingKey *mappingKey in array) {
                value = [mappingKey valueWithObject:value];
            }
            if(value) break;
        }
        if([classInfo.clazz respondsToSelector:@selector(wd_newValueFromOldValue:propertyInfo:)]) {
            value = [classInfo.clazz wd_newValueFromOldValue:value propertyInfo:propertyInfo];
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
                value = [self modelWithJson:value classInfo:classInfo];
            } else if(typeClazz && arrayClazz) { //数组类型
                if([value isKindOfClass:[NSArray class]]) {
                    if(!propertyInfo.isArrayClazzFromFoundation) {
                        WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:arrayClazz];
                        value = [self modelArrayWithJsonArray:value classInfo:classInfo];
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
                        NSNumber *num = [WDJsonKitTool createNumberWithObject:value];
                        [WDJsonKitTool setupNumberTypeWithModel:model number:num propertyInfo:propertyInfo];
                        continue;
                    }
                } else if([value isKindOfClass:[NSNumber class]]) {
                    if(propertyType.isNumberType && propertyInfo.assigmnetType == WDAssignmentTypeMessage) {
                        NSNumber *num = (NSNumber *)value;
                        [WDJsonKitTool setupNumberTypeWithModel:model number:num propertyInfo:propertyInfo];
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

- (NSArray *)modelArrayWithJsonArray:(id)json classInfo:(WDClassInfo *)classInfo
{
    if([json isKindOfClass:[NSString class]]) {
        json = [WDJsonKitTool objectWithJsonString:json];
    } else if([json isKindOfClass:[NSData class]]) {
        json = [WDJsonKitTool objectWithData:json];
    }
    if(![json isKindOfClass:[NSArray class]]) return nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(id object in json) {
        if([object isKindOfClass:[NSArray class]]) {
            NSArray *array = [self modelArrayWithJsonArray:object classInfo:classInfo];
            if(array.count) {
                [tmpArray addObjectsFromArray:array];
            }
        } else if([object isKindOfClass:[NSDictionary class]]) {
            id model = [self modelWithJson:object classInfo:classInfo];
            if(model) {
                [tmpArray addObject:model];
            }
        }
    }
    return tmpArray;
}

- (NSDictionary *)jsonWithModel:(WDClassInfo *)classInfo
{
    if(!classInfo) return nil;
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    for(WDPropertyInfo *propertyInfo in classInfo.propertyCache) {
        WDPropertyTypeInfo *propertyType = propertyInfo.type;
        id value = nil;
        if(propertyType.isNumberType) {
            value = [WDJsonKitTool numberTypeWithModel:classInfo.object propertyInfo:propertyInfo];
        } else {
            value = ((id (*)(id, SEL))(void *) objc_msgSend)(classInfo.object,propertyInfo.getter);
        }
        if(!value) continue;
        @try {
            Class typeClazz = propertyType.typeClass;
            if(!propertyType.isFromFoundation && typeClazz) { //对象类型
                WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:typeClazz];
                classInfo.object = value;
                value = [self jsonWithModel:classInfo];
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
                    id tempInnerContainer = [mappingKey valueWithObject:innerContainer];
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

- (NSArray *)jsonArrayWithModelArray:(NSArray *)model
{
    if(![model isKindOfClass:[NSArray class]]) return nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for(id obj in model) {
        if(![WDJsonKitTool classFromFoundation:[obj class]]) {
            WDClassInfo *classInfo = [[WDJsonKitManager sharedManager].cache classInfoFromCache:[obj class]];
            classInfo.object = obj;
            id dict = [self jsonWithModel:classInfo];
            if(dict) {
                [tmpArray addObject:dict];
            }
            
        } else {
            [tmpArray addObject:obj];
        }
    }
    
    return tmpArray;
}

- (void)encodeWithCoder:(NSCoder *)aCoder classInfo:(WDClassInfo *)classInfo
{
    for(WDPropertyInfo *propertyInfo in classInfo.encodingPropertyCache) {
        WDPropertyTypeInfo *propertyType = propertyInfo.type;
        id value = nil;
        if(propertyType.isNumberType) {
            value = [WDJsonKitTool numberTypeWithModel:classInfo.object propertyInfo:propertyInfo];
        } else {
            value = ((id (*)(id, SEL))(void *) objc_msgSend)(classInfo.object,propertyInfo.getter);
        }
        if(!value || !propertyInfo.name) continue;
        [aCoder encodeObject:value forKey:propertyInfo.name];
    }
}

- (void)decodeWithCoder:(NSCoder *)aDecoder classInfo:(WDClassInfo *)classInfo
{
    for(WDPropertyInfo *propertyInfo in classInfo.encodingPropertyCache) {
        if(!propertyInfo.name) continue;
        WDPropertyTypeInfo *type = propertyInfo.type;
        id value  = [aDecoder decodeObjectForKey:propertyInfo.name];
        if(!value) continue;
        if(type.isNumberType) {
            value = (NSNumber *)value;
            [WDJsonKitTool setupNumberTypeWithModel:classInfo.object number:value propertyInfo:propertyInfo];
        } else {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)(classInfo.object, propertyInfo.setter, (id)value);
        }
    }
}

@end

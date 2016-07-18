//
//  WDJsonKitTool.m
//  WDJsonKit
//
//  Created by 王迪 on 16/7/18.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDJsonKitTool.h"
#import "WDPropertyInfo.h"
#import "WDPropertyTypeInfo.h"
#import <objc/message.h>

@implementation WDJsonKitTool

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

+ (void)setupNumberTypeWithModel:(id)model number:(NSNumber *)num propertyInfo:(WDPropertyInfo *)propertyInfo
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

+ (NSNumber *)numberTypeWithModel:(id)model propertyInfo:(WDPropertyInfo *)propertyInfo
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

+ (id)objectWithJsonString:(NSString *)json
{
    if(!json) return nil;
    return [self objectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (id)objectWithData:(NSData *)data
{
    if(!data) return nil;
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(!error) return jsonDict;
    return nil;
}

@end

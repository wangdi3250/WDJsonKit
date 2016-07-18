//
//  WDPropertyTypeInfo.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDPropertyTypeInfo.h"
#import "WDClassInfo.h"
#import "WDJsonKitTool.h"

@implementation WDPropertyTypeInfo

#pragma mark 初始化方法
+ (instancetype)wd_propertyTypeWithTypeCode:(NSString *)typeCode
{
    WDPropertyTypeInfo *typeInfo = [[self alloc] init];
    typeInfo.typeCode  = typeCode;
    return typeInfo;
}
#pragma mark - C函数工具处理方法
static inline WDEncodingType wd_encodingGetType(const char *typeEncoding)
{
    char *type = (char *)typeEncoding;
    if (!type) return WDEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return WDEncodingTypeUnknown;
    switch (*type) {
        case 'v': return WDEncodingTypeVoid;
        case 'B': return WDEncodingTypeBool;
        case 'c': return WDEncodingTypeInt8;
        case 'C': return WDEncodingTypeUInt8;
        case 's': return WDEncodingTypeInt16;
        case 'S': return WDEncodingTypeUInt16;
        case 'i': return WDEncodingTypeInt32;
        case 'I': return WDEncodingTypeUInt32;
        case 'l': return WDEncodingTypeInt32;
        case 'L': return WDEncodingTypeUInt32;
        case 'q': return WDEncodingTypeInt64;
        case 'Q': return WDEncodingTypeUInt64;
        case 'f': return WDEncodingTypeFloat;
        case 'd': return WDEncodingTypeDouble;
        case 'D': return WDEncodingTypeLongDouble;
        case '#': return WDEncodingTypeClass;
        case ':': return WDEncodingTypeSEL;
        case '*': return WDEncodingTypeCString;
        case '^': return WDEncodingTypePointer;
        case '[': return WDEncodingTypeCArray;
        case '(': return WDEncodingTypeUnion;
        case '{': return WDEncodingTypeStruct;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return WDEncodingTypeBlock;
            else return WDEncodingTypeObject;
        }
        default: return WDEncodingTypeUnknown;
    }
}

static inline BOOL wd_encodingTypeIsNumberType(WDEncodingType type)
{
    switch (type) {
        case WDEncodingTypeBool:
        case WDEncodingTypeInt8:
        case WDEncodingTypeUInt8:
        case WDEncodingTypeInt16:
        case WDEncodingTypeUInt16:
        case WDEncodingTypeInt32:
        case WDEncodingTypeUInt32:
        case WDEncodingTypeInt64:
        case WDEncodingTypeUInt64:
        case WDEncodingTypeFloat:
        case WDEncodingTypeDouble:
        case WDEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

#pragma mark 重写stter
- (void)setTypeCode:(NSString *)typeCode
{
    _typeCode = typeCode;
    _encodingType = wd_encodingGetType(typeCode.UTF8String);
    _numberType = wd_encodingTypeIsNumberType(_encodingType);
        if(typeCode.length > 3 && [typeCode hasPrefix:@"@\""]) {
            _typeCode = [typeCode substringWithRange:NSMakeRange(2, typeCode.length - 3)];
            _typeClass = NSClassFromString(_typeCode);
            _fromFoundation = [WDJsonKitTool classFromFoundation:_typeClass];
            _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
    }
}

@end

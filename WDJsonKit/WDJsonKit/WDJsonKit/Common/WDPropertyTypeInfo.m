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

+ (instancetype)wd_propertyTypeWithTypeCode:(NSString *)typeCode
{
    WDPropertyTypeInfo *typeInfo = [[self alloc] init];
    typeInfo.typeCode  = typeCode;
    return typeInfo;
}

- (void)setTypeCode:(NSString *)typeCode
{
    _typeCode = typeCode;
    _encodingType = [WDJsonKitTool encodingGetType:typeCode.UTF8String];
    _numberType = [WDJsonKitTool encodingTypeIsNumberType:_encodingType];
        if(typeCode.length > 3 && [typeCode hasPrefix:@"@\""]) {
            _typeCode = [typeCode substringWithRange:NSMakeRange(2, typeCode.length - 3)];
            _typeClass = NSClassFromString(_typeCode);
            _fromFoundation = [WDJsonKitTool classFromFoundation:_typeClass];
            _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
    }
}

@end

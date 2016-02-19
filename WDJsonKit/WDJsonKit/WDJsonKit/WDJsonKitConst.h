//
//  WDJsonKitConst.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 映射key的类型的枚举
 */
typedef enum
{
    WDMappingKeyTypeDictionary,
    WDMappingKeyTypeArray
    
}WDMappingKeyType;

typedef enum{
    
    WDEncodingTypeUnknown, ///< unknown
    WDEncodingTypeVoid, ///< void
    WDEncodingTypeBool, ///< bool
    WDEncodingTypeInt8, ///< char / BOOL
    WDEncodingTypeUInt8, ///< unsigned char
    WDEncodingTypeInt16, ///< short
    WDEncodingTypeUInt16, ///< unsigned short
    WDEncodingTypeInt32, ///< int
    WDEncodingTypeUInt32, ///< unsigned int
    WDEncodingTypeInt64, ///< long long
    WDEncodingTypeUInt64, ///< unsigned long long
    WDEncodingTypeFloat, ///< float
    WDEncodingTypeDouble, ///< double
    WDEncodingTypeLongDouble, ///< long double
    WDEncodingTypeObject, ///< id
    WDEncodingTypeClass, ///< Class
    WDEncodingTypeSEL, ///< SEL
    WDEncodingTypeBlock, ///< block
    WDEncodingTypePointer, ///< void*
    WDEncodingTypeStruct, ///< struct
    WDEncodingTypeUnion, ///< union
    WDEncodingTypeCString, ///< char*
    WDEncodingTypeCArray, ///< char[10] (for example)
    WDEncodingTypePropertyReadonly, ///< readonly
    WDEncodingTypePropertyCopy, ///< copy
    WDEncodingTypePropertyRetain, ///< retain
    WDEncodingTypePropertyNonatomic, ///< nonatomic
    WDEncodingTypePropertyWeak, ///< weak
    WDEncodingTypePropertyCustomGetter, ///< getter=
    WDEncodingTypePropertyCustomSetter, ///< setter=
    WDEncodingTypePropertyDynamic ///< @dynamic
}WDEncodingType;

typedef enum
{
    WDAssignmentTypeMessage,
    WDAssignmentTypeKVC
    
}WDAssignmentType;

#define WDCoding \
- (void)encodeWithCoder:(NSCoder *)aCoder \
{\
    [self wd_encodeWithCoder:aCoder]; \
}\
\
- (instancetype)initWithCoder:(NSCoder *)aDecoder \
{\
    if(self = [super init]) { \
        [self wd_decodeWithCoder:aDecoder]; \
    } \
    return self; \
}

/**
 *  数据库相关
 */
extern NSString * const WDDBName;
extern NSString * const WDINTEGER_TYPE;
extern NSString * const WDTEXT_TYPE;
extern NSString * const WDREAL_TYPE;
extern NSString * const WDBLOB_TYPE;
extern NSString * const WDDATE_TYPE;

extern NSString * const WDNSString;
extern NSString * const WDNSMutableString;
extern NSString * const WDNSInteger;
extern NSString * const WDNSURL;
extern NSString * const WDNSUInteger;
extern NSString * const WDCGFloat;
extern NSString * const WDfloat;
extern NSString * const WDdouble;
extern NSString * const WDEnum_int;
extern NSString * const WDBOOL;
extern NSString * const WDNSData;
extern NSString * const WDNSMutableData;
extern NSString * const WDNSArray;
extern NSString * const WDNSMutableArray;
extern NSString * const WDNSDate;
extern NSString * const WDNSDictionary;
extern NSString * const WDNSMutableDictionary;

extern NSString * const WDaID;
extern NSString * const WDModelIdentify;
extern NSString * const WDaModel;
extern NSString * const WDaModelID;
extern NSString * const WDNSNumber;
extern NSString * const WDStringIdentify;


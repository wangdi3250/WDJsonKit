//
//  WDDog.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDDog.h"
//#import "WDExtension.h"

@implementation WDDog
WDCoding
//+ (NSString *)WD_replacedKeyFromPropertyName121:(NSString *)propertyName
//{
//    // nickName -> nick_name
//    return [propertyName underlineFromCamel];
//}

+ (NSArray *)wd_encodingPropertyBlackList
{
    return @[@"nickName",@"runSpeed"];
}

@end

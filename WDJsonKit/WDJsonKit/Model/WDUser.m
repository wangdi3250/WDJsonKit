//
//  WDUser.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDUser.h"
#import "WDJsonKit.h"

@implementation WDUser
WDCoding
+ (NSString *)wd_sqlRowIdentifyPropertyName
{
    return @"uID";
}

@end

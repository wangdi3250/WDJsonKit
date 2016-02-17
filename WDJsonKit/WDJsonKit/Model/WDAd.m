//
//  WDAD.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDAd.h"

@implementation WDAd

+ (NSDictionary *)wd_sqlClassInArray
{
    return @{
             @"datas" : [NSData class],
             @"urlArray" : [NSString class]
             };
}

@end

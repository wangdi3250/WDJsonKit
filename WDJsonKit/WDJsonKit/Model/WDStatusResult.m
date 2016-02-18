//
//  WDStatusResult.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//
#import "WDStatusResult.h"

@implementation WDStatusResult

+ (NSDictionary *)wd_classInArray
{
    return @{
             @"statuses" : @"WDStatus",
             @"ads" : @"WDAd"
             };
}
@end

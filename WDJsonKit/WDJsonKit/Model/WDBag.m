//
//  WDBag.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDBag.h"

@implementation WDBag

//+ (NSArray *)WD_ignoredCodingPropertyNames
//{
//    return @[@"name"];
//}
+ (NSString *)wd_sqlRowIdentifyPropertyName
{
    return @"gID";
}

@end

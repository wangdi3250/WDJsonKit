//
//  NSDate+WDJsonKit.m
//  WDJsonKit
//
//  Created by 王迪 on 16/2/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "NSDate+WDJsonKit.h"

@implementation NSDate (WDJsonKit)

- (NSString *)wd_dateStringWithDateFormatter:(NSString *)dateFormatter
{
    if(!dateFormatter || !self) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormatter;
    return [formatter stringFromDate:self];
}

@end

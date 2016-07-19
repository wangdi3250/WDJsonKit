//
//  WDBook.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDBook.h"

@implementation WDBook
//- (id)WD_newValueFromOldValue:(id)oldValue property:(WDProperty *)property
//{
//    if ([property.name isEqualToString:@"publisher"]) {
//        if (oldValue == nil) return @"";
//    } else if (property.type.typeClass == [NSDate class]) {
//        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//        fmt.dateFormat = @"yyyy-MM-dd";
//        return [fmt dateFromString:oldValue];
//    }
//    
//    return oldValue;
//}
+ (NSString *)wd_sqlRowIdentifyPropertyName
{
    return @"bID";
}
@end

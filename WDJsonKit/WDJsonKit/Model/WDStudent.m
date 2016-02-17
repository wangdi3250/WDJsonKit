//
//  WDSudent.m
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDStudent.h"

@implementation WDStudent
+ (NSDictionary *)wd_sqlReplaceKeysFromOriginKeys
{
    return @{@"sID" : @"wd_id",
             @"desc" : @"desciption",
             @"oldName" : @"wd_old_name",
             @"nowName" : @"wd_now_name",
             @"nameChangedTime" : @"wd_name_changed_time",
             @"bag" : @"wd_bag"
             };
}

+ (NSDictionary *)wd_sqlClassInArray
{
    return @{@"books" : @"WDBook"};
}

+ (NSDictionary *)wd_replaceKeysFromOriginKeys
{
    return @{@"sID" : @"id",
             @"desc" : @"desciption",
             @"oldName" : @"name.oldName",
             @"nowName" : @"name.newName",
             @"nameChangedTime" : @"name.info[1].nameChangedTime",
             @"bag" : @"other.bag"
             };
}

+ (NSDictionary *)wd_classInArray
{
    return @{@"books" : @"WDBook"};
}
+ (NSString *)wd_sqlRowIdentifyPropertyName
{
    return @"sID";
}

@end

//
//  WDJsonKitManager.m
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDJsonKitManager.h"

@interface WDJsonKitManager()

@property (nonatomic, strong) NSMutableArray *tableNameArray;

@end

@implementation WDJsonKitManager

static id _instance;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (NSMutableArray *)tableNameArray
{
    if(!_tableNameArray) {
        _tableNameArray = [NSMutableArray array];
    }
    return _tableNameArray;
}

- (BOOL)containsTableName:(NSString *)tableName
{
    if(!tableName) return NO;
    return [self.tableNameArray containsObject:tableName];
}

@end

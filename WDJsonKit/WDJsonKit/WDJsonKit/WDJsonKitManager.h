//
//  WDJsonKitManager.h
//  WDJsonKit
//
//  Created by 王迪 on 16/6/28.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDJsonKitManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)containsTableName:(NSString *)tableName;

@end

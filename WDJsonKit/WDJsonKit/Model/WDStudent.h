//
//  WDStudent.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKit.h"
@class WDBag,WDStatus;

@interface WDStudent : NSObject
@property (assign, nonatomic) NSInteger sID;
@property (copy, nonatomic) NSString *otherName;
@property (copy, nonatomic) NSString *nowName;
@property (copy, nonatomic) NSString *oldName;
@property (copy, nonatomic) NSString *nameChangedTime;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) WDBag *bag;
@property (strong, nonatomic) NSArray *books;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) WDStatus *status;
@end

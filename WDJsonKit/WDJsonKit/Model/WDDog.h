//
//  WDDog.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKit.h"
@interface WDDog : NSObject <NSCoding>
@property (copy, nonatomic) NSString *nickName;
@property (assign, nonatomic) double salePrice;
@property (assign, nonatomic) double runSpeed;
@end

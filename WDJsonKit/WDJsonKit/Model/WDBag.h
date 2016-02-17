//
//  WDBag.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKit.h"

@interface WDBag : NSObject
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) double price;
@property (nonatomic, assign) NSInteger gID;
@end

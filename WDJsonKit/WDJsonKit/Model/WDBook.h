//
//  WDBook.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WDJsonKit.h"
@class WDBox;

@interface WDBook : NSObject
@property (nonatomic, assign) NSInteger bID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *publisher;
@property (strong, nonatomic) NSString *publishedTime;
//@property (strong, nonatomic) WDBox *box;
@end

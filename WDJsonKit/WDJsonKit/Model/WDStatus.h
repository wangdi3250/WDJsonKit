//
//  WDStatus.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WDUser;

@interface WDStatus : NSObject
/** 微博文本内容 */
@property (copy, nonatomic) NSString *text;
/** 微博作者 */
@property (strong, nonatomic) WDUser *user;
/** 转发的微博 */
@property (strong, nonatomic) WDStatus *retweetedStatus;
@end
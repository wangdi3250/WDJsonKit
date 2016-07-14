//
//  NSDate+WDJsonKit.h
//  WDJsonKit
//
//  Created by 王迪 on 16/2/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WDJsonKit)
/**
 *  将NSDate按照一定的格式转换成字符串
 *
 *  @param dateFormatter 格式
 *
 *  @return 转换后的字符串
 */
- (NSString *)wd_dateStringWithDateFormatter:(NSString *)dateFormatter;

@end

//
//  NSString+WDJsonKit.h
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKitConst.h"

@interface NSString (WDJsonKit)
/**
 *  解析映射的key
 *
 *  @param block block
 */
- (void)wd_enumerateMappingKeyUsingBlock:(void (^)(WDMappingKeyType type,NSString *name))block;
/**
 *  构造setter方法
 *
 *  @return 构造之后的setter方法
 */
- (NSString *)wd_createSetter;
/**
 *  首字母变大写
 *
 *  @return 首字母变大写的串
 */
- (NSString *)wd_firstCharUpper;
/**
 *  将字符串变成URL
 *
 *  @return URL
 */
- (NSURL *)wd_url;
/**
 *  拼接沙盒目录
 *
 *  @return 拼接好的路径
 */
- (NSString *)wd_appendDocumentPath;
/**
 *  将字符串转换NSDate
 *
 *  @param dateFormatter 转换格式
 *
 *  @return NSDate
 */
- (NSDate *)wd_dateWithFormatter:(NSString *)dateFormatter;

@end

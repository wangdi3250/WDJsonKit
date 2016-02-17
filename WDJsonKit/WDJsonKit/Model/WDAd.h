//
//  WDAD.h
//  WDJsonModel
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDJsonKit.h"
@interface WDAd : NSObject
/** 广告图片 */
@property (copy, nonatomic) NSString *image;
/** 广告url */
@property (strong, nonatomic) NSURL *url;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) NSArray *urlArray;
@end

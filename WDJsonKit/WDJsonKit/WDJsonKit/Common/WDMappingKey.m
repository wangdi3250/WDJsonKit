//
//  WDMappingKey.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/14.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "WDMappingKey.h"

@implementation WDMappingKey

- (id)valueWithObject:(id)object
{
    if(!object || !self.name) return nil;
    if(self.type == WDMappingKeyTypeDictionary && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)object;
        return dict[self.name];
    } else if(self.type == WDMappingKeyTypeArray && [object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)object;
        return array[self.name.intValue];
    }
    return nil;
}

@end

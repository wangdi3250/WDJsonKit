//
//  WDKVStorage.h
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDKVStorageItem : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSData *value;
@property (nonatomic, assign) NSTimeInterval accessTime;
@property (nonatomic, assign) int size;
@property (nonatomic, copy) NSString *fileName;

@end

@interface WDKVStorage : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName;
- (WDKVStorageItem *)itemWithKey:(NSString *)key;
- (BOOL)removeItemWithKey:(NSString *)key;
- (BOOL)itemExistsWithKey:(NSString *)key;
- (BOOL)removeAllItems;
- (BOOL)removeItemsToFitCount:(NSUInteger)count;
- (BOOL)removeItemsToFitSize:(NSUInteger)size;
- (BOOL)removeItemsThatMoreThanTime:(int)time;

@end

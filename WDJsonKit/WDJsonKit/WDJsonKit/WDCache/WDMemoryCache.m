//
//  WDMemoryCache.m
//  WDCache
//
//  Created by 王迪 on 16/5/15.
//  Copyright © 2016年 wangdi. All rights reserved.
//

#import "WDMemoryCache.h"
#import <UIKit/UIKit.h>

@interface WDDoubleLinkListNode : NSObject

@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@property (nonatomic, weak) WDDoubleLinkListNode *preNode;
@property (nonatomic, weak) WDDoubleLinkListNode *nextNode;
@property (nonatomic, assign) NSUInteger cost;

@end

@implementation WDDoubleLinkListNode

@end

@interface WDDoubleLinkList : NSObject

@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, assign) NSUInteger totalCost;
@property (nonatomic, strong) WDDoubleLinkListNode *headerNode;
@property (nonatomic, strong) WDDoubleLinkListNode *footerNode;
@property (nonatomic, strong) NSMutableDictionary *linkListCacheDict;
- (void)insertNodeToHeader:(WDDoubleLinkListNode *)node;
- (void)bringNodeToHeader:(WDDoubleLinkListNode *)node;
- (void)removeNode:(WDDoubleLinkListNode *)node;
- (void)removeAllNode;

@end

@implementation WDDoubleLinkList

- (NSMutableDictionary *)linkListCacheDict
{
    if(!_linkListCacheDict) {
        _linkListCacheDict = [NSMutableDictionary dictionary];
    }
    return _linkListCacheDict;
}

- (void)insertNodeToHeader:(WDDoubleLinkListNode *)node
{
    if(!node.key) return;
    self.linkListCacheDict[node.key] = node;
    self.totalCount++;
    self.totalCost += node.cost;
    if(self.headerNode) {
        node.nextNode = self.headerNode;
        self.headerNode.preNode = node;
        self.headerNode = node;
    } else {
        self.headerNode = self.footerNode = node;
    }
}

- (void)bringNodeToHeader:(WDDoubleLinkListNode *)node
{
    if(!node.key) return;
    if(node == self.headerNode) return;
    if(node == self.footerNode) {
        self.footerNode = node.preNode;
        self.footerNode.nextNode = nil;
    } else {
        node.preNode.nextNode = node.nextNode;
        node.nextNode.preNode = node.preNode;
    }
    self.headerNode.preNode = node;
    node.nextNode = self.headerNode;
    self.headerNode = node;
}

- (void)removeNode:(WDDoubleLinkListNode *)node
{
    if(!node.key) return;
    if(!self.linkListCacheDict[node.key]) return;
    [self.linkListCacheDict removeObjectForKey:node.key];
    self.totalCount--;
    self.totalCost -= node.cost;
    if(node.nextNode) {
        node.preNode.nextNode = node.nextNode;
    }
    if(node.preNode) {
        node.nextNode.preNode = node.preNode;
    }
    if(self.headerNode == node) {
        self.headerNode = node.nextNode;
    }
    if(self.footerNode == node) {
        self.footerNode = node.preNode;
    }
}

- (void)removeFooterNode
{
    if(!self.footerNode) return;
    self.totalCount--;
    self.totalCost -= self.footerNode.cost;
    [self.linkListCacheDict removeObjectForKey:self.footerNode.key];
    if(self.headerNode == self.footerNode) {
        self.headerNode = self.footerNode = nil;
    } else {
        self.headerNode = self.headerNode.preNode;
        self.headerNode.nextNode = nil;
    }
}

- (void)removeAllNode
{
    self.totalCount = 0;
    self.totalCost = 0;
    self.headerNode = self.footerNode = nil;
    [self.linkListCacheDict removeAllObjects];
}

@end

@interface WDMemoryCache()

@property (nonatomic, strong) dispatch_semaphore_t lockSemaphore;
@property (nonatomic, strong) WDDoubleLinkList *doubleLinkList;

@end

@implementation WDMemoryCache

- (instancetype)init
{
    if(self = [super init]) {
        _lockSemaphore = dispatch_semaphore_create(1);
        _doubleLinkList = [[WDDoubleLinkList alloc] init];
        _autoTrimInterval = 60;
        _ageLimit = DBL_MAX;
        _countLimit = NSUIntegerMax;
        _countLimit = NSUIntegerMax;
        _shouldRemoveAllObjectsWhenMemoryWarning = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWaringNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self setObject:object forKey:key cost:0];
}
- (void)setObject:(id)object forKey:(id)key cost:(NSUInteger)cost
{
    if(!key) return;
    if(!object) {
        [self removeObjectForKey:key];
        return;
    }
    [self lock];
    WDDoubleLinkListNode *node = self.doubleLinkList.linkListCacheDict[key];
    if(node) {
        self.doubleLinkList.totalCost -= node.cost;
        self.doubleLinkList.totalCost += cost;
        node.cost = cost;
        node.value = object;
        [self.doubleLinkList bringNodeToHeader:node];
        
    } else {
        node = [[WDDoubleLinkListNode alloc] init];
        node.key = key;
        node.cost = cost;
        node.value = object;
        [self.doubleLinkList insertNodeToHeader:node];
    }
    if(self.doubleLinkList.totalCount > self.countLimit) {
        [self.doubleLinkList removeFooterNode];
    }
    [self unLock];
}

- (id)objectForKey:(id)key
{
    if(!key) return nil;
    [self lock];
    WDDoubleLinkListNode *node = self.doubleLinkList.linkListCacheDict[key];
    [self.doubleLinkList bringNodeToHeader:node];
    [self unLock];
    return node.value;
}

- (void)removeObjectForKey:(id)key
{
    if(!key) return;
    [self lock];
    WDDoubleLinkListNode *node = self.doubleLinkList.linkListCacheDict[key];
    [self.doubleLinkList removeNode:node];
    [self unLock];
}

- (void)removeAllObjects
{
    [self lock];
    [self.doubleLinkList removeAllNode];
    [self unLock];
}

- (BOOL)containsObjectForKey:(id)key
{
    if(!key) return NO;
    [self lock];
    BOOL contains = self.doubleLinkList.linkListCacheDict[key];
    [self unLock];
    return contains;
}

- (void)lock
{
    dispatch_semaphore_wait(self.lockSemaphore, DISPATCH_TIME_FOREVER);
    
}

- (void)unLock
{
    dispatch_semaphore_signal(self.lockSemaphore);
}

- (void)didReceiveMemoryWaringNotification
{
    if(self.shouldRemoveAllObjectsWhenMemoryWarning) {
        [self removeAllObjects];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

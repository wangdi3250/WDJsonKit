//
//  NSString+WDJsonKit.m
//  WDJsonModel
//
//  Created by 王迪 on 16/1/16.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "NSString+WDJsonKit.h"

@implementation NSString (WDJsonKit)

- (void)wd_enumerateMappingKeyUsingBlock:(void (^)(WDMappingKeyType, NSString *))block
{
    NSArray *keysArray = [self componentsSeparatedByString:@"."];
    if(!keysArray.count && block) {
        block(WDMappingKeyTypeDictionary,self);
        return;
    }
    for(NSString *key in keysArray) {
        NSRange leftBracesRange = [key rangeOfString:@"["];
        if(leftBracesRange.location != NSNotFound) {
            NSString *firstKey = [key substringToIndex:leftBracesRange.location];
            if(firstKey) {
                if(block) {
                    block(WDMappingKeyTypeDictionary,firstKey);
                }
            }
            NSRange rightBracesRange = [key rangeOfString:@"]"];
            if(rightBracesRange.location != NSNotFound) {
                
                NSRange lastKeyRange = NSMakeRange(leftBracesRange.location + 1, rightBracesRange.location - (leftBracesRange.location + leftBracesRange.length));
                NSString *secondKey = [key substringWithRange:lastKeyRange];
                if(secondKey) {
                    if(block) {
                        block(WDMappingKeyTypeArray,secondKey);
                    }
                }
            }
        } else {
            if(block) {
                block(WDMappingKeyTypeDictionary,key);
            }
        }
    }
}
- (NSString *)wd_createSetter
{
    if(!self.length) return nil;
    NSMutableString *setterStr = [NSMutableString stringWithString:@"set"];
    [setterStr appendString:[self wd_firstCharUpper]];
    [setterStr appendString:@":"];
    return setterStr;
}

- (NSString *)wd_firstCharUpper
{
    if(!self.length) return nil;
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].uppercaseString];
    if (self.length >= 2) [string appendString:[self substringFromIndex:1]];
    return string;
}

- (NSURL *)wd_url
{
    return [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8))];
}

- (NSString *)wd_appendDocumentPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [path stringByAppendingPathComponent:self];
}

- (NSDate *)wd_dateWithFormatter:(NSString *)dateFormatter
{
    if(!dateFormatter || !self) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormatter;
    return [formatter dateFromString:self];
}

@end

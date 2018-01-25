//
//  Base64.h
//  360WiFi
//
//  Created by huuang on 14-3-19.
//  Copyright (c) 2014年 qihoo360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

+ (NSString*)encodeBase64String:(NSString *)input;
+ (NSString*)decodeBase64String:(NSString *)input;
+ (NSString*)encodeBase64Data:(NSData *)data;
+ (NSString*)decodeBase64Data:(NSData *)data;
+ (NSData*)decodeBase64DataReturnData:(NSData *)data;

@end

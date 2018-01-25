//
//  NSString+Addition.h
//  360CloudSDK
//
//  Created by ai zhongyuan on 13-1-21.
//  Copyright (c) 2013年 QIHU. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonCryptor.h>

@interface NSString (URLCode)

- (NSString *)URLEncode;

- (NSString *)URLDecode;

@end

@interface NSString (MD5Encode)

- (NSString *)MD5Encode;

@end

@interface NSString (SQLEncode)

//- (NSString *)SQLEncode;

@end

@interface NSString (DESEncryptOrDecrypt)

- (NSString*)DESBase64WithECB:(BOOL)ecbMode
             encryptOrDecrypt:(CCOperation)encryptOrDecrypt
                          key:(NSString*)key;
@end

@interface NSString (PathExtensions)

- (NSString*)removeLastPathCharacter;

- (NSString *)firstPathComponent;

- (NSString *)stringByDeletingFirstPathComponent;

@end

@interface NSString (Truncate)

// "0123456789" (maxLen:7)-> "01...89"
- (NSString *) stringWithMiddleTruncate:(NSUInteger)maxLen;

// "0123456789" (maxLen:7)-> "0123..."
- (NSString *) stringWithTailTruncate:(NSUInteger)maxLen;

// "0123456789" (maxLen:7)-> "...6789"
- (NSString *) stringWithHeadTruncate:(NSUInteger)maxLen;

@end

@interface NSString (UTF8Chinese)

// 判断字符是否全为中文
- (BOOL)isAllUTF8Chinese;
/*! 是否包含 4 字节的 emoji 表情 */
- (BOOL)has4BytesEmoji;

@end

@interface NSString (UnknownEncoding)

+ (NSString *)stringWithUnknownEncodingData:(NSData *)data;

@end

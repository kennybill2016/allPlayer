//
//  NSData+Addition.h
//  360CloudSDK
//
//  Created by ai zhongyuan on 13-1-21.
//  Copyright (c) 2013年 QIHU. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonCryptor.h>

@interface NSData (MD5Encode)

- (NSString *)MD5Encode;

@end

@interface NSData (SHA1)

- (NSString *)SHA1Digest;

- (NSString *)SHA1Digest:(NSUInteger) length;

@end

@interface NSData (AESEncryptOrDecrypt)

- (NSData *)qcAesEncrypt;

- (NSData *)qcAesDecrypt;

- (NSData *)aesEncrypt:(const char *)key iv:(const char *)iv;

- (NSData *)aesDecrypt:(const char *)key iv:(const char *)iv;

@end

@interface NSData (DESEncryptOrDecrypt)

- (NSData*)DESWithECB:(BOOL)ecbMode
     encryptOrDecrypt:(CCOperation)encryptOrDecrypt
                  key:(NSString*)key;

- (NSData*)DESBase64WithECB:(BOOL)ecbMode
           encryptOrDecrypt:(CCOperation)encryptOrDecrypt
                        key:(NSString*)key;

@end

@interface DataEncodingLen : NSObject

@property (assign, nonatomic) NSUInteger stringEncoding;
@property (assign, nonatomic) NSUInteger bomLen;

+ (id)dataEncodeWithLen:(NSInteger)stringEncoding len:(NSUInteger)bomLen;

@end

@interface NSData (DataEncoding)

- (BOOL)isUTF8Encoding;

// 获取Data的编码格式及编码标识的长度
- (DataEncodingLen*)getDataEncodingAndBomLen;

@end

@interface NSData (uint)

- (uint16_t)getUint16WithStart:(NSUInteger)start bigEndian:(BOOL)flag;

- (uint32_t)getUint32WithStart:(NSUInteger)start bigEndian:(BOOL)flag;

- (uint64_t)getUint64WithStart:(NSUInteger)start bigEndian:(BOOL)flag;

@end

@interface NSData (DDData)

//解压缩
- (NSData *)gzipInflate;
//压缩
- (NSData *)gzipDeflate;

@end

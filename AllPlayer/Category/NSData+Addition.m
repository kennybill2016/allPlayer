//
//  NSData+Addition.m
//  360CloudSDK
//
//  Created by ai zhongyuan on 13-1-21.
//  Copyright (c) 2013年 QIHU. All rights reserved.
//

#import "NSData+Addition.h"
#import "GTMBase64.h"
#include "sha1.h"
#import "zlib.h"

#import <CommonCrypto/CommonDigest.h>

#define QC_AES_IV GetQCAesIV()
#define QC_AES_KEY GetQCAesKey()

static const char * GetQCAesIV()
{
    static char iv[18];
    static bool initialized = false;
    if (initialized == false) {
        int i=0;
        iv[i++]='1';
        iv[i++]='7';
        iv[i++]='6';
        iv[i++]='1';
        iv[i++]='f';
        iv[i++]='f';
        iv[i++]='0';
        iv[i++]='5';
        iv[i++]='e';
        iv[i++]='d';
        iv[i++]='7';
        iv[i++]='6';
        iv[i++]='a';
        iv[i++]='7';
        iv[i++]='c';
        iv[i++]='a';
        iv[i]='\0';
        initialized = true;
    }
    return iv;
}

static const char * GetQCAesKey()
{
    static char key[34];
    static bool initialized = false;
    if (initialized == false) {
        int i=0;
        key[i++]='7';
        key[i++]='4';
        key[i++]='a';
        key[i++]='9';
        key[i++]='a';
        key[i++]='a';
        key[i++]='7';
        key[i++]='1';
        key[i++]='c';
        key[i++]='d';
        key[i++]='f';
        key[i++]='e';
        key[i++]='a';
        key[i++]='5';
        key[i++]='4';
        key[i++]='1';
        key[i++]='1';
        key[i++]='2';
        key[i++]='e';
        key[i++]='b';
        key[i++]='1';
        key[i++]='6';
        key[i++]='a';
        key[i++]='4';
        key[i++]='e';
        key[i++]='e';
        key[i++]='7';
        key[i++]='6';
        key[i++]='7';
        key[i++]='1';
        key[i++]='a';
        key[i++]='8';
        key[i]='\0';
        initialized = true;
    }
    return key;
}

@implementation NSData (MD5Encode)

- (NSString *)MD5Encode
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (CC_LONG)[self length], result);
	
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

@end

@implementation NSData (SHA1)

- (NSString *)SHA1Digest
{
    return [self SHA1Digest:[self length]];
}

- (NSString *)SHA1Digest:(NSUInteger) length
{
    unsigned char result[20];
    
    /*CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    CC_SHA1_Update(&ctx, [self bytes], (CC_LONG)length);
    CC_SHA1_Final(result, &ctx);*/
    
    SHA_CTX ctx;
    SHAInit(&ctx);
    SHAUpdate(&ctx, (BYTE *)[self bytes], (int)length);
    SHAFinal(result, &ctx);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
            ];
}

@end

@implementation NSData (AESEncryptOrDecrypt)

- (NSData *)qcAesEncrypt
{
    return [self aesOperation:kCCEncrypt key:QC_AES_KEY iv:QC_AES_IV];
}

- (NSData *)qcAesDecrypt
{
    return [self aesOperation:kCCDecrypt key:QC_AES_KEY iv:QC_AES_IV];
}

- (NSData *)aesEncrypt:(const char *)key iv:(const char *)iv
{
    return [self aesOperation:kCCEncrypt key:key iv:iv];
}

- (NSData *)aesDecrypt:(const char *)key iv:(const char *)iv
{
    return [self aesOperation:kCCDecrypt key:key iv:iv];
}

- (NSData *)aesOperation:(CCOperation)op key:(const char *)key iv:(const char *)iv {
    
    assert(key != NULL);
    
    NSMutableData * outData = [[NSMutableData alloc] initWithLength:[self length]];
    
    // Data out parameters
    size_t outMoved = 0;
    CCCryptorStatus status = kCCSuccess;
    status = CCCrypt(op, kCCAlgorithmAES128, kCCOptionPKCS7Padding, key, kCCKeySizeAES256, iv,
                     [self bytes], [self length], (void *)[outData bytes], [outData length], &outMoved);
    
    if(status == kCCBufferTooSmall) {
        
        [outData setLength:outMoved];
        
        status = CCCrypt(op,kCCAlgorithmAES128, kCCOptionPKCS7Padding, key, kCCKeySizeAES256, iv,
                         [self bytes], [self length], (void *)[outData bytes], [outData length], &outMoved);
    }
    
    if(status == kCCSuccess) {
        if (outMoved < [outData length]) {
            [outData setLength:outMoved];
        }
        return outData;
    } 
    
    return nil;
}

@end

@implementation NSData (DESEncryptOrDecrypt)

- (NSData*)DESWithECB:(BOOL)ecbMode
     encryptOrDecrypt:(CCOperation)encryptOrDecrypt
                  key:(NSString*)key
{
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [key UTF8String];
    
    CCOptions options = kCCOptionPKCS7Padding;
    if ( ecbMode) {
        options |= kCCOptionECBMode;
    }
    
    CCCryptorStatus ccStatus;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = ([self length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    NSMutableData * outData = [[NSMutableData alloc] initWithLength:bufferPtrSize];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       options,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       [self bytes],
                       [self length],
                       (void *)[outData bytes],
                       bufferPtrSize,
                       &movedBytes);
    
    if ( ccStatus == kCCBufferTooSmall) {
        
        bufferPtrSize = movedBytes;
        [outData setLength:bufferPtrSize];
        
        ccStatus = CCCrypt(encryptOrDecrypt,
                           kCCKeySize3DES,
                           options,
                           vkey,
                           kCCKeySize3DES,
                           vinitVec,
                           [self bytes],
                           [self length],
                           (void *)[outData bytes],
                           bufferPtrSize,
                           &movedBytes);
    }
    
    if ( ccStatus == kCCSuccess) {
        if ( movedBytes < [outData length]) {
            [outData setLength:movedBytes];
        }
    }
    
    return outData;
}

- (NSData*)DESBase64WithECB:(BOOL)ecbMode
           encryptOrDecrypt:(CCOperation)encryptOrDecrypt
                        key:(NSString*)key
{
    NSData * inData = nil;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        inData = [GTMBase64 decodeData:self];
    }
    else
    {
        inData = self;
    }
    
    NSData * outData = [inData DESWithECB:ecbMode encryptOrDecrypt:encryptOrDecrypt key:key];
    
    if (encryptOrDecrypt == kCCEncrypt)
    {
        outData = [GTMBase64 encodeData:outData];
    }
    
    return outData;
}

@end

@implementation DataEncodingLen

+ (id)dataEncodeWithLen:(NSInteger)stringEncoding len:(NSUInteger)bomLen
{
    DataEncodingLen* dataEncoding = [[DataEncodingLen alloc] init];
    dataEncoding.bomLen = bomLen;
    dataEncoding.stringEncoding = stringEncoding;
    return dataEncoding;
}

@end

@implementation NSData (DataEncoding)

- (BOOL)isUTF8Encoding
{
    int iUTF8Count = 0;
    int iASCIICount = 0;
    
    unsigned char* start = (unsigned char*)[self bytes];
    unsigned char* end = (unsigned char*)start + [self length];
    
    while (start < end)
    {
        if (*start < 0x80) // (10000000): 值小于0x80的为ASCII字符
        {
            ++start;
            
            ++iASCIICount;
            
            if (iASCIICount + iUTF8Count > 50) {
                // 检查了50个字符，退出循环
                break;
            }
        }
        else if (*start < (0xC0)) // (11000000): 值介于0x80与0xC0之间的为无效UTF-8字符
        {
            return NO;
        }
        else if (*start < (0xE0)) // (11100000): 此范围内为2字节UTF-8字符
        {
            if (start >= end - 1)
                break;
            if ((start[1] & (0xC0)) != 0x80)
            {
                return NO;
            }
            
            start += 2;
            
            ++iUTF8Count;
            
            if (iASCIICount + iUTF8Count > 50) {
                // 检查了50个字符，退出循环
                break;
            }
        }
        else if (*start < (0xF0)) // (11110000): 此范围内为3字节UTF-8字符
        {
            if (start >= end - 2)
                break;
            if ((start[1] & (0xC0)) != 0x80 || (start[2] & (0xC0)) != 0x80)
            {
                return NO;
            }
            
            start += 3;
            
            ++iUTF8Count;
            
            if (iASCIICount + iUTF8Count > 50) {
                // 检查了50个字符，退出循环
                break;
            }
        }
        else
        {
            return NO;
        }
    }
    
    if (iUTF8Count > 0) {
        return YES;
    }
    
    return NO;
}

// Bytes        Encoding Form
// 00 00 FE FF	UTF-32, big-endian
// FF FE 00 00	UTF-32, little-endian
// FE FF        UTF-16, big-endian
// FF FE        UTF-16, little-endian
// EF BB BF     UTF-8
- (DataEncodingLen*)getDataEncodingAndBomLen
{
    const unsigned char * bytes = (const unsigned char *)[self bytes];
    
    if ([self length] >= 2) {
        
        // UTF-16, big-endian
        if (bytes[0] == 0xFE &&
            bytes[1] == 0xFF) {
            return [DataEncodingLen dataEncodeWithLen:NSUTF16BigEndianStringEncoding len:2];
        }
        
        // UTF-16, little-endian
        if (bytes[0] == 0xFF &&
            bytes[1] == 0xFE) {
            return [DataEncodingLen dataEncodeWithLen:NSUTF16LittleEndianStringEncoding len:2];
        }
    }
    
    if ([self length] >= 3) {
        
        // UTF-8
        if (bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF) {
            return [DataEncodingLen dataEncodeWithLen:NSUTF8StringEncoding len:3];
        }
    }
    
    if ([self length] >= 4) {
        
        // UTF-32, big-endian
        if (bytes[0] == 0x00 &&
            bytes[1] == 0x00 &&
            bytes[2] == 0xFE &&
            bytes[3] == 0xFF) {
            return [DataEncodingLen dataEncodeWithLen:NSUTF32BigEndianStringEncoding len:4];
        }
        
        // UTF-32, little-endian
        if (bytes[0] == 0xFF &&
            bytes[1] == 0xFE &&
            bytes[2] == 0x00 &&
            bytes[3] == 0x00) {
            return [DataEncodingLen dataEncodeWithLen:NSUTF32BigEndianStringEncoding len:4];
        }
    }
    
    // 根据UTF-8编码特征检查是否为UTF-8编码
    if ([self isUTF8Encoding]) {
        return [DataEncodingLen dataEncodeWithLen:NSUTF8StringEncoding len:0];
    }
    return [DataEncodingLen dataEncodeWithLen:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) len:0];
}

@end

@implementation NSData (uint)

- (uint16_t)getUint16WithStart:(NSUInteger)start bigEndian:(BOOL)flag {
    
    uint16_t ret = 0;
    
    [self getBytes:&ret range:NSMakeRange(start, sizeof(uint16_t))];
    
    if (flag) {
        ret = NSSwapBigShortToHost(ret);
    }else {
        ret = NSSwapLittleShortToHost(ret);
    }
    
    return ret;
}

- (uint32_t)getUint32WithStart:(NSUInteger)start bigEndian:(BOOL)flag {
    
    uint32_t ret = 0;
    
    [self getBytes:&ret range:NSMakeRange(start, sizeof(uint32_t))];
    
    if (flag) {
        ret = NSSwapBigIntToHost(ret);
    }else {
        ret = NSSwapLittleIntToHost(ret);
    }
    
    return ret;
}

- (uint64_t)getUint64WithStart:(NSUInteger)start bigEndian:(BOOL)flag {
    
    uint64_t ret = 0;
    
    [self getBytes:&ret range:NSMakeRange(start, sizeof(uint64_t))];
    
    if (flag) {
        ret = NSSwapBigLongLongToHost(ret);
    }else {
        ret = NSSwapLittleLongLongToHost(ret);
    }
    
    return ret;
}

@end

@implementation NSData (DDData)

//解压缩
- (NSData *)gzipInflate {
    if ([self length] == 0)
        return self;
    unsigned full_length = (int)[self length];
    unsigned half_length = (int)[self length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length]; BOOL done = NO;
    int status = 0;
    z_stream strm;
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = (int)[self length];
    strm.total_out = 0;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    
    while (!done) { // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        
        strm.next_out = (Bytef*)[decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uint)[decompressed length] - (uint)strm.total_out;
        // Inflate another chunk. status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
            done = YES;
        else if (status != Z_OK)
            break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else
        return nil;
}

//压缩
- (NSData *)gzipDeflate
{
    if ([self length] == 0) return self;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[self bytes];
    strm.avail_in = (int)[self length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = (Bytef*)[compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)[compressed length] - (uint)strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

@end

//
//  Tools.m
//  QihooQRCode
//
//  Created by lijinwei on 2017/3/10.
//  Copyright © 2017年 赵天福. All rights reserved.
//

#import "Tools.h"
#include <sys/sysctl.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#import <arpa/inet.h>
#include <net/if.h>

#import "NSString+Addition.h"
#import "HUAJSONKit.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define IP_MASK_IPv4    @"mask_ipv4"
#define IP_MASK_IPv6    @"mask_ipv6"

@implementation QRCodeObject

@end

@implementation Tools

+ (NSString *) uniqueGlobalDeviceIdentifier{
    NSUUID * aid = [[UIDevice currentDevice] identifierForVendor];
    NSLog(@"aid ===== %@", [aid UUIDString]);
    NSString* uniqueIdentifier = nil;
    if(uniqueIdentifier==nil)
        uniqueIdentifier = [[aid UUIDString] MD5Encode];
    return uniqueIdentifier;
}

+ (NSString*) getNance:(NSString*)time deviceid:(NSString*)devid randomTick:(NSString*)rtick
{
    NSString* verify = [NSString stringWithFormat:@"%@%@%@",
                        time, devid,rtick];
    NSString* verifyMD5 = [verify MD5Encode];
    
    return verifyMD5;
}

+ (NSString*)generateSignString:(NSString*) strData
{
    if( strData == nil)
        return nil;
    
    const char* strChar = [strData UTF8String];
    
    size_t length = strlen(strChar);
    char *newChar = (char*)malloc(length+1);
    memset(newChar, 0, length+1);
    
    int i = 0;
    for (i = 0; i < length; i ++)
    {
        if ((i % 4) == 0)
        {
            newChar[i] = 'A';
        }
        else if ((i % 2) == 0)
        {
            newChar[i] = 'M';
        }
        else
        {
            newChar[i] = strChar[i];
        }
    }
    NSString *results = [NSString stringWithCString:newChar encoding:NSUTF8StringEncoding];
    free(newChar);
    return results;
}

+ (NSString*) genQRParams:(NSDictionary*)myParams
{
    NSString* rtick = [[NSString alloc] initWithFormat:@"%u",arc4random()];
    NSString* devid = [Tools uniqueGlobalDeviceIdentifier];
    NSString* curtime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString* nance = [self getNance:curtime deviceid:devid?:@"" randomTick:rtick?:@""];
    
    NSMutableDictionary* defaultParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     devid,@"m2",
     nance, @"n",
     nil];
    [defaultParams addEntriesFromDictionary:myParams];
    
    NSMutableString* result = [[NSMutableString alloc] initWithCapacity:100];
    NSString* key;
    NSArray *allKeys = [defaultParams allKeys];
    NSCountedSet *sets = [[NSCountedSet alloc] initWithArray:allKeys];
    NSArray *sortKeys = [[sets allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString* result_1 = [[NSMutableString alloc] initWithCapacity:100];
    for(key in sortKeys){
        id value = [defaultParams objectForKey:key];
        NSString *value1 = nil;
        if ([value isKindOfClass:[NSNumber class]]) {
            value1 = [[value stringValue] URLEncode];
        }else if ([value isKindOfClass:[NSString class]]){
            value1 = [value URLEncode];
        }
        if( result_1.length > 0 )
            [result_1 appendString:@"&"];
        [result_1 appendFormat:@"%@=%@", key, value1];
    }
    result = result_1;
    NSString* newSignString = [Tools generateSignString:result];
    NSString* strRemovedChar = [newSignString stringByAppendingString:@"0c0cde0f10e48e3c240762ef45d43340"];
    NSString *signStr = [strRemovedChar MD5Encode];
    [result_1 appendFormat:@"&%@=%@", @"sign", signStr];

    return result;
}

+ (NSString*) generateDesKey:(NSString*)method
{
     NSString* devid = [Tools uniqueGlobalDeviceIdentifier];
    NSString *unicomString = [[NSString stringWithFormat:@"%@%@", method, devid?:@""] MD5Encode];
    NSString *result = [unicomString substringWithRange: NSMakeRange(3, 24)];
    return result;
}

+ (NSDictionary*) genQRPostParams:(NSString*)method params:(NSDictionary*)myParams
{
    NSString* deviceType = [Tools getDeviceType];
    
    NSMutableDictionary* defaultParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     [Tools IPhoneAppVersion],@"v",
     @"iphone",@"devtype",
     @"100008",@"channel",
     deviceType, @"model",
     @"apple",@"manufacturer",
     nil];
    [defaultParams addEntriesFromDictionary:myParams];
    
    NSString* jsonString = [defaultParams JSONString];
//    NSString* deskey = [Tools generateDesKey:method];
//    NSString * rawValue = [jsonString DESBase64WithECB:YES encryptOrDecrypt:kCCEncrypt key:deskey];
//    
    NSMutableDictionary* postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:jsonString?jsonString:@"",@"params",nil];
    
    return postParams;
}

+ (NSString *)IPhoneAppVersion
{
    static NSString* version = nil;
    if(version == nil){
        NSBundle * mainBoundle = [NSBundle mainBundle];
        NSString * versionNumber = [mainBoundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        //NSString * buildNumber = [mainBoundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        version = [NSString stringWithFormat:@"%@", versionNumber];
        version = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    return version;
}

//获取设备类型
+ (NSString*)getDeviceVersionInfo
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    void *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString* machineName = [NSString stringWithFormat:@"%s", machine];
    
    free(machine);
    return machineName;
}

+ (NSString *)getDeviceType
{
    NSString *correspondVersion = [self getDeviceVersionInfo];
    
    if ([correspondVersion isEqualToString:@"iPhone3,1"] || [correspondVersion isEqualToString:@"iPhone3,2"])
        return@"iPhone 4";
    if ([correspondVersion isEqualToString:@"iPhone4,1"])
        return@"iPhone 4S";
    if ([correspondVersion isEqualToString:@"iPhone5,1"] || [correspondVersion isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";
    if ([correspondVersion isEqualToString:@"iPhone5,3"] || [correspondVersion isEqualToString:@"iPhone5,4"])
        return @"iPhone 5C";
    if ([correspondVersion isEqualToString:@"iPhone6,1"] || [correspondVersion isEqualToString:@"iPhone6,2"])
        return @"iPhone 5S";
    
    if ([correspondVersion isEqualToString:@"iPhone7,1"])    return @"iPhone 6+";
    if ([correspondVersion isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    
    if ([correspondVersion isEqualToString:@"i386"])        return@"Simulator";
    if ([correspondVersion isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([correspondVersion isEqualToString:@"iPhone1,1"])   return@"iPhone 1";
    if ([correspondVersion isEqualToString:@"iPhone1,2"])   return@"iPhone 3";
    if ([correspondVersion isEqualToString:@"iPhone2,1"])   return@"iPhone 3S";
    
    if ([correspondVersion isEqualToString:@"iPod1,1"])     return@"iPod Touch 1";
    if ([correspondVersion isEqualToString:@"iPod2,1"])     return@"iPod Touch 2";
    if ([correspondVersion isEqualToString:@"iPod3,1"])     return@"iPod Touch 3";
    if ([correspondVersion isEqualToString:@"iPod4,1"])     return@"iPod Touch 4";
    if ([correspondVersion isEqualToString:@"iPod5,1"])     return@"iPod Touch 5";
    
    if ([correspondVersion isEqualToString:@"iPad1,1"])     return@"iPad 1";
    if ([correspondVersion isEqualToString:@"iPad2,1"] || [correspondVersion isEqualToString:@"iPad2,2"] || [correspondVersion isEqualToString:@"iPad2,3"] || [correspondVersion isEqualToString:@"iPad2,4"])
        return@"iPad 2";
    if ([correspondVersion isEqualToString:@"iPad2,5"] || [correspondVersion isEqualToString:@"iPad2,6"] || [correspondVersion isEqualToString:@"iPad2,7"] )
        return @"iPad Mini";
    if ([correspondVersion isEqualToString:@"iPad3,1"] || [correspondVersion isEqualToString:@"iPad3,2"] || [correspondVersion isEqualToString:@"iPad3,3"] || [correspondVersion isEqualToString:@"iPad3,4"] || [correspondVersion isEqualToString:@"iPad3,5"] || [correspondVersion isEqualToString:@"iPad3,6"])
        return @"iPad 3";
    
    return correspondVersion;
}

//WIFI:SDF;T:WPA;P:SSDF;
//smsto:12313:123123123123
//contact:MECARD:N:刘瑞康;ORG:360公司;TEL:185 0006 7412;EMAIL:tianxingjianlrk@163.com;TIL:码农;NOTE:别给别人说我是CEO哈！;:
/*
BEGIN:VCARD
VERSION:3.0
FN:张三
TEL:121339
EMAIL:112122@163.com
ADR:东北
END:VCARD
*/
+ (QRCodeObject*)getContentQRCodeType:(NSString*)content {
    
    QRCodeObject* obj = [[QRCodeObject alloc] init];
    if(content.length<5) {
        obj.type = QRCodeType_TEXT;
        obj.action = @"text";
        obj.title = @"文字内容";
        obj.btnText=@"复制";
        obj.btnDefaultText=@"复制";
        obj.arrItem = @[@{@"key":@"",@"val":content}];
        obj.arrBtns = @[@{@"button_txt":@"复制"}];
        return obj;
    }
    
    content = [content lowercaseString];
    content = [content stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([content hasPrefix:@"http://"]||[content hasPrefix:@"https://"]) {
        obj.type = QRCodeType_URL;
        obj.action = @"openurl";
        NSString* urlDomain = [[NSURL URLWithString:content] host];
        obj.title = urlDomain;
        obj.dicDetail = @{
                          @"txt": @"<span style=\"font-size:16px; color:#ff6918;\">网络异常：</span><span style=\"font-size:16px;color:#151600;\">安全解析失败</span>",
                          @"desc": @"请检查您的网络状态"
                          };
        obj.btnText=@"重试";
        obj.btnDefaultText=@"重试";
        obj.arrItem = @[@{@"key":@"来自",@"val":urlDomain}];
        obj.arrBtns = @[@{@"button_txt":@"重试"}];
        return obj;
    }
    else if([content hasPrefix:@"wifi:"]) {
        obj.type = QRCodeType_WiFi;
        obj.action = @"wifi";
        obj.title = @"WiFi";
        obj.dicDetail = @{
                       @"txt": @"<span style=\"font-size:16px; color:#ff6918;\">注意：</span><span style=\"font-size:16px;color:#151600;\">谨防钓鱼WiFi</span>",
                       @"desc": @"建议使用安全软件检测"
                       };
        content = [content substringFromIndex:@"wifi:".length];
        NSMutableArray* arrList = [NSMutableArray new];
        NSArray* itemArrays = [content componentsSeparatedByString:@";"];
        for(NSString* item in itemArrays) {
            NSArray* itemArrays1 = [item componentsSeparatedByString:@":"];
            if(itemArrays1.count==2) {
                NSString* leftKey = itemArrays1[0];
                NSString* rightValue = itemArrays1[1];
                if(leftKey.length>0&&rightValue.length>0) {
                    if([leftKey isEqualToString:@"s"] ) {
                        [arrList addObject:@{@"key":@"SSID",@"val":rightValue}];
                    }
                    else if([leftKey isEqualToString:@"p"]){
                        [arrList addObject:@{@"key":@"密码",@"val":rightValue}];
                    }
                    else if([leftKey isEqualToString:@"t"]){
                        [arrList addObject:@{@"key":@"加密",@"val":rightValue}];
                    }
                }
            }
        }
        obj.arrItem = arrList;
        return obj;
    }
    else if([content hasPrefix:@"smsto:"]) {
        obj.type = QRCodeType_MSG;
        obj.action = @"sms";
        obj.title = @"短信息";
        obj.btnText=@"发送";
        obj.btnDefaultText=@"发送";
        obj.dicDetail = @{
                       @"txt": @"<span style=\"font-size:16px; color:#ff6918;\">注意：</span><span style=\"font-size:16px;color:#151600;\">切勿相信未知号码短信</span>",
                       @"desc": @"回复陌生号码短信前，请先核实对方身份"
                       };
        NSMutableArray* arrList = [NSMutableArray new];
        NSArray* itemArrays = [content componentsSeparatedByString:@":"];
        if(itemArrays&&itemArrays.count==3) {
            [arrList addObject:@{@"key":@"号码",@"val":itemArrays[1]}];
            [arrList addObject:@{@"key":@"内容",@"val":itemArrays[2]}];
        }
        obj.arrItem = arrList;
        obj.arrBtns = @[@{@"button_txt":@"发送"}];
        return obj;
    }
    else if([content hasPrefix:@"mecard:"]) {
        obj.type = QRCodeType_CONTACT;
        obj.action = @"contact";
        obj.title = @"联系人名片";
        obj.btnText=@"添加至联系人";
        obj.btnDefaultText=@"添加至联系人";
        
        content = [content substringFromIndex:@"mecard:".length];
        
        NSMutableArray* arrList = [NSMutableArray new];
        NSArray* itemArrays = [content componentsSeparatedByString:@";"];
        BOOL insertHeader = NO;
        for(NSString* item in itemArrays)
        {
            NSArray* itemArrays1 = [item componentsSeparatedByString:@":"];
            if(itemArrays1.count==2) {
                NSString* leftKey = itemArrays1[0];
                NSString* rightValue = itemArrays1[1];
                if(leftKey.length>0&&rightValue.length>0) {
                    if([leftKey isEqualToString:@"n"] ) {
                        insertHeader = YES;
                        leftKey = @"姓名";
                        [arrList insertObject:@{@"key":leftKey,@"val":rightValue} atIndex:0];
                    }
                    else if([leftKey isEqualToString:@"tel"]){
                        leftKey = @"电话";
                        if(insertHeader) {
                            [arrList insertObject:@{@"key":leftKey,@"val":rightValue} atIndex:1];
                        }
                        else {
                            [arrList insertObject:@{@"key":leftKey,@"val":rightValue} atIndex:0];
                        }
                    }
                    if([leftKey isEqualToString:@"org"] ) {
                        leftKey = @"公司";
                        [arrList addObject:@{@"key":leftKey,@"val":rightValue}];
                    }
                    if([leftKey isEqualToString:@"til"] ) {
                        leftKey = @"职务";
                        [arrList addObject:@{@"key":leftKey,@"val":rightValue}];
                    }
                }
            }
        }
        obj.arrItem = arrList;
        obj.arrBtns = @[@{@"button_txt":@"添加至联系人"}];
        return obj;
    }
    else if([content hasPrefix:@"begin:vcard"] && [content rangeOfString:@"end:vcard"].length!=NSNotFound) {
        NSRange endRange = [content rangeOfString:@"end:vcard"];
        obj.type = QRCodeType_CONTACT;
        obj.action = @"contact";
        obj.title = @"联系人名片";
        obj.btnText=@"添加至联系人";
        obj.btnDefaultText=@"添加至联系人";
        
        NSInteger beginLen = @"begin:vcard".length;
        
        content = [content substringWithRange:NSMakeRange(beginLen, endRange.location-beginLen)];
        content = [content stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
        NSMutableArray* arrList = [NSMutableArray new];
        NSArray* itemArrays = [content componentsSeparatedByString:@"\n"];
        BOOL insertHeader = NO;
        for(NSString* item in itemArrays)
        {
            NSArray* itemArrays1 = [item componentsSeparatedByString:@":"];
            if(itemArrays1.count==2) {
                NSString* leftKey = itemArrays1[0];
                NSString* rightValue = itemArrays1[1];
                if(leftKey.length>0&&rightValue.length>0) {
                    if([leftKey isEqualToString:@"fn"] ) {
                        insertHeader = YES;
                        leftKey = @"姓名";
                        [arrList insertObject:@{@"key":leftKey,@"val":rightValue} atIndex:0];
                    }
                    else if([leftKey isEqualToString:@"tel"]){
                        leftKey = @"电话";
                        if(insertHeader) {
                            [arrList insertObject:@{@"key":leftKey,@"val":rightValue} atIndex:1];
                        }
                        else {
                            [arrList insertObject:@{@"key":leftKey,@"val":rightValue} atIndex:0];
                        }
                    }
                    if([leftKey isEqualToString:@"org"] ) {
                        leftKey = @"公司";
                        [arrList addObject:@{@"key":leftKey,@"val":rightValue}];
                    }
                    if([leftKey isEqualToString:@"til"] ) {
                        leftKey = @"职务";
                        [arrList addObject:@{@"key":leftKey,@"val":rightValue}];
                    }
                }
            }
        }
        obj.arrItem = arrList;
        obj.arrBtns = @[@{@"button_txt":@"添加至联系人"}];
        return obj;
    }
    else {
        obj.type = QRCodeType_TEXT;
        obj.action = @"text";
        obj.title = @"文本内容";
        obj.btnText=@"复制";
        obj.btnDefaultText=@"复制";
        obj.arrItem = @[@{@"key":@"",@"val":content}];
        obj.arrBtns = @[@{@"button_txt":@"复制"}];
    }
    return obj;
}

/*! 获取 WLAN IP 地址 */
+ (NSString *)getWlanIPAddress
{
    BOOL isWlanIp = NO;
    
    NSString *address = [self getCurrentIPAddress: &isWlanIp];
    
    if (isWlanIp == NO) {
//        address = nil;
    }
    
    return address;
}

/*!
 *    获取设备当前的 IP 地址。
 *    优先获取 WLAN 地址，其不存在时再获取 WWAN 地址；优先获取 IPv4 地址，其不存在时再获取 IPv6 地址
 */
+ (NSString *)getCurrentIPAddress:(BOOL *)isWlanIp
{
    NSDictionary *dictionary = [self getIPAddresses];
    
    NSString *address = dictionary[@"en0/ipv4"];
    if (isWlanIp) {
        *isWlanIp = YES;
    }
    
    //169.254.0.0-169.254.255.255，是保留地址段，开启了dhcp服务的设备但又无法获取到dhcp的会随机使用这个网段的 ip
    if (address.length == 0 || [address hasPrefix: @"169.254"]) {
        address = dictionary[@"en0/ipv6"];
        if (isWlanIp) {
            *isWlanIp = YES;
        }
    }
    
    if (address.length == 0) {
        address = dictionary[@"pdp_ip0/ipv4"];
        if (isWlanIp) {
            *isWlanIp = NO;
        }
    }
    
    if (address.length == 0) {
        address = dictionary[@"pdp_ip0/ipv6"];
        if (isWlanIp) {
            *isWlanIp = NO;
        }
    }
    
    return address;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
            
            const struct sockaddr_in *netmask = (const struct sockaddr_in *)interface->ifa_netmask;
            if(netmask && (netmask->sin_family == AF_INET || netmask->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type = nil;
                if (netmask->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &netmask->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_MASK_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *netmask = (const struct sockaddr_in6 *)interface->ifa_netmask;
                    if(inet_ntop(AF_INET6, &netmask->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_MASK_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String: addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSStringEncoding)guessEncoding:(NSData *)data{
    NSStringEncoding systemEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringGetSystemEncoding());
    BOOL assumeShiftJIS = systemEncoding == NSShiftJISStringEncoding || systemEncoding == NSJapaneseEUCStringEncoding;

    // For now, merely tries to distinguish ISO-8859-1, UTF-8 and Shift_JIS,
    // which should be by far the most common encodings.
    //int length = bytes.length;
    NSInteger length = data.length;

    BOOL canBeISO88591 = YES;
    BOOL canBeShiftJIS = YES;
    BOOL canBeUTF8 = YES;
    int utf8BytesLeft = 0;
    //int utf8LowChars = 0;
    int utf2BytesChars = 0;
    int utf3BytesChars = 0;
    int utf4BytesChars = 0;
    int sjisBytesLeft = 0;
    //int sjisLowChars = 0;
    int sjisKatakanaChars = 0;
    //int sjisDoubleBytesChars = 0;
    int sjisCurKatakanaWordLength = 0;
    int sjisCurDoubleBytesWordLength = 0;
    int sjisMaxKatakanaWordLength = 0;
    int sjisMaxDoubleBytesWordLength = 0;
    //int isoLowChars = 0;
    //int isoHighChars = 0;
    int isoHighOther = 0;
    
    const unsigned char * bytes = (const unsigned char *)[data bytes];
    
    BOOL utf8bom = NO;//length > 3 &&
//    bytes[0] == (int8_t) 0xEF &&
//    bytes[1] == (int8_t) 0xBB &&
//    bytes[2] == (int8_t) 0xBF;
    
    for (int i = 0;
         i < length && (canBeISO88591 || canBeShiftJIS || canBeUTF8);
         i++) {
        
        int value = bytes[i] & 0xFF;
        
        // UTF-8 stuff
        if (canBeUTF8) {
            if (utf8BytesLeft > 0) {
                if ((value & 0x80) == 0) {
                    canBeUTF8 = NO;
                } else {
                    utf8BytesLeft--;
                }
            } else if ((value & 0x80) != 0) {
                if ((value & 0x40) == 0) {
                    canBeUTF8 = NO;
                } else {
                    utf8BytesLeft++;
                    if ((value & 0x20) == 0) {
                        utf2BytesChars++;
                    } else {
                        utf8BytesLeft++;
                        if ((value & 0x10) == 0) {
                            utf3BytesChars++;
                        } else {
                            utf8BytesLeft++;
                            if ((value & 0x08) == 0) {
                                utf4BytesChars++;
                            } else {
                                canBeUTF8 = NO;
                            }
                        }
                    }
                }
            } //else {
            //utf8LowChars++;
            //}
        }
        
        // ISO-8859-1 stuff
        if (canBeISO88591) {
            if (value > 0x7F && value < 0xA0) {
                canBeISO88591 = NO;
            } else if (value > 0x9F) {
                if (value < 0xC0 || value == 0xD7 || value == 0xF7) {
                    isoHighOther++;
                } //else {
                //isoHighChars++;
                //}
            } //else {
            //isoLowChars++;
            //}
        }
        
        // Shift_JIS stuff
        if (canBeShiftJIS) {
            if (sjisBytesLeft > 0) {
                if (value < 0x40 || value == 0x7F || value > 0xFC) {
                    canBeShiftJIS = NO;
                } else {
                    sjisBytesLeft--;
                }
            } else if (value == 0x80 || value == 0xA0 || value > 0xEF) {
                canBeShiftJIS = NO;
            } else if (value > 0xA0 && value < 0xE0) {
                sjisKatakanaChars++;
                sjisCurDoubleBytesWordLength = 0;
                sjisCurKatakanaWordLength++;
                if (sjisCurKatakanaWordLength > sjisMaxKatakanaWordLength) {
                    sjisMaxKatakanaWordLength = sjisCurKatakanaWordLength;
                }
            } else if (value > 0x7F) {
                sjisBytesLeft++;
                //sjisDoubleBytesChars++;
                sjisCurKatakanaWordLength = 0;
                sjisCurDoubleBytesWordLength++;
                if (sjisCurDoubleBytesWordLength > sjisMaxDoubleBytesWordLength) {
                    sjisMaxDoubleBytesWordLength = sjisCurDoubleBytesWordLength;
                }
            } else {
                //sjisLowChars++;
                sjisCurKatakanaWordLength = 0;
                sjisCurDoubleBytesWordLength = 0;
            }
        }
    }
    
    if (canBeUTF8 && utf8BytesLeft > 0) {
        canBeUTF8 = NO;
    }
    if (canBeShiftJIS && sjisBytesLeft > 0) {
        canBeShiftJIS = NO;
    }
    
    // Easy -- if there is BOM or at least 1 valid not-single byte character (and no evidence it can't be UTF-8), done
    if (canBeUTF8 && (utf8bom || utf2BytesChars + utf3BytesChars + utf4BytesChars > 0)) {
        return NSUTF8StringEncoding;
    }
    // Easy -- if assuming Shift_JIS or at least 3 valid consecutive not-ascii characters (and no evidence it can't be), done
    if (canBeShiftJIS && (assumeShiftJIS || sjisMaxKatakanaWordLength >= 3 || sjisMaxDoubleBytesWordLength >= 3)) {
        return NSShiftJISStringEncoding;
    }
    // Distinguishing Shift_JIS and ISO-8859-1 can be a little tough for short words. The crude heuristic is:
    // - If we saw
    //   - only two consecutive katakana chars in the whole text, or
    //   - at least 10% of bytes that could be "upper" not-alphanumeric Latin1,
    // - then we conclude Shift_JIS, else ISO-8859-1
    if (canBeISO88591 && canBeShiftJIS) {
        return (sjisMaxKatakanaWordLength == 2 && sjisKatakanaChars == 2) || isoHighOther * 10 >= length
        ? NSShiftJISStringEncoding : NSISOLatin1StringEncoding;
    }
    
    // Otherwise, try in order ISO-8859-1, Shift JIS, UTF-8 and fall back to default platform encoding
    if (canBeISO88591) {
        return NSISOLatin1StringEncoding;
    }
    if (canBeShiftJIS) {
        return NSShiftJISStringEncoding;
    }
    if (canBeUTF8) {
        return NSUTF8StringEncoding;
    }
    // Otherwise, we take a wild guess with platform encoding
    return systemEncoding;
}

/**
 *  总的空间
 */
+ (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    return [fattributes objectForKey:NSFileSystemSize];
}

/**
 *  剩余空间
 */
+ (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

/**
 *  已用空间
 */
+ (NSNumber *)haveUseDiskSpace
{
    CGFloat totalDiskSpace = [[Tools totalDiskSpace] floatValue];
    CGFloat freeDiskSpace = [[Tools freeDiskSpace] floatValue];
    CGFloat haveUseDiskSpace = totalDiskSpace - freeDiskSpace;
    
    return [NSNumber numberWithFloat:haveUseDiskSpace];
}

/**
 *  总空间Str
 */
+ (NSString *)haveTotalDiskSpaceStr
{
    CGFloat haveUseDiskSpace = [[Tools totalDiskSpace] floatValue];
    
    if (haveUseDiskSpace >= 1024*1024*1024)
    {
        return [NSString stringWithFormat:@"%.1fG",haveUseDiskSpace/(1024*1024*1024.00)];
    }
    
    return [NSString stringWithFormat:@"%.1fM",haveUseDiskSpace/(1024*1024.00)];
}

/**
 *  已用空间Str
 */
+ (NSString *)haveUseDiskSpaceStr
{
    CGFloat haveUseDiskSpace = [[Tools haveUseDiskSpace] floatValue];
    
    if (haveUseDiskSpace >= 1024*1024*1024)
    {
        return [NSString stringWithFormat:@"%.1fG",haveUseDiskSpace/(1024*1024*1024.00)];
    }
    
    return [NSString stringWithFormat:@"%.1fM",haveUseDiskSpace/(1024*1024.00)];
}

/**
 *  剩余空间Str
 */
+ (NSString *)freeDiskSpaceStr
{
    CGFloat freeDiskSpace = [[Tools freeDiskSpace] floatValue];
    
    if (freeDiskSpace >= 1024*1024*1024)
    {
        return [NSString stringWithFormat:@"%.1fG",freeDiskSpace/(1024*1024*1024.00)];
    }
    
    return [NSString stringWithFormat:@"%.1fM",freeDiskSpace/(1024*1024.00)];
}

@end

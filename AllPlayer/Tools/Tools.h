//
//  Tools.h
//  QihooQRCode
//
//  Created by lijinwei on 2017/3/10.
//  Copyright © 2017年 赵天福. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define QRCODE_CONF_URL @"https://msic.360.cn/intf.php"
#define CLOUD_ERROR_NO_KEY @"errno"
#define CLOUD_ERROR_MSG_KEY @"errmsg"

typedef NS_ENUM(NSInteger,QRCodeType) {
    QRCodeType_URL=0,
    QRCodeType_MSG,
    QRCodeType_CONTACT,
    QRCodeType_WiFi,
    QRCodeType_TEXT
};

@interface QRCodeObject : NSObject

@property (nonatomic,assign) QRCodeType type;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *btnText;
@property (nonatomic, strong) NSString *btnDefaultText;
@property (nonatomic, strong) NSArray *arrItem;
@property (nonatomic, strong) NSDictionary* dicDetail;
@property (nonatomic, strong) NSArray *arrBtns;

@end

@interface Tools : NSObject

+ (NSString *) uniqueGlobalDeviceIdentifier;

+ (NSString*) getNance:(NSString*)time deviceid:(NSString*)devid randomTick:(NSString*)rtick;

+ (NSString*) genQRParams:(NSDictionary*)myParams;
+ (NSDictionary*) genQRPostParams:(NSString*)method params:(NSDictionary*)myParams;

+ (NSString*) generateDesKey:(NSString*)method;

+ (NSString *)getDeviceType;

+ (QRCodeObject*)getContentQRCodeType:(NSString*)content;

+ (NSString *)getWlanIPAddress;

+ (NSStringEncoding)guessEncoding:(NSData *)data;

+ (NSString *)freeDiskSpaceStr;
+ (NSString *)haveUseDiskSpaceStr;

@end

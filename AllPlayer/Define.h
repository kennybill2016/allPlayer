//
//  QHDefine.h
//  QihooQRCode
//
//  Created by 赵天福 on 2017/3/10.
//  Copyright © 2017年 赵天福. All rights reserved.
//

#ifndef QHDefine_h
#define QHDefine_h

#define kScreenWidth ([[UIScreen mainScreen]bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen]bounds].size.height)
#define FLEXIBLE_WIDTH(x) ((x) / 375.0 * kScreenWidth)
#define FLEXIBLE_HEIGHT(x) ((x) / 667.0 * kScreenHeight)

#define kFontDefaultType                       @"PingFangSC-Regular"
#define kFontDefaultBoldType                   @"PingFangSC-Medium"

#define UICOLOR_ARGB(color) [UIColor colorWithRed: ((((unsigned int)color) >> 16) & 0xFF) / 255.0 green: ((((unsigned int)color) >> 8) & 0xFF) / 255.0 blue: (((unsigned int)color) & 0xFF) / 255.0 alpha: ((((unsigned int)color) >> 24) & 0xFF) / 255.0]


#ifdef DEBUG 
    #define NSLog(...) NSLog(__VA_ARGS__)
#else
    #define NSLog(...)
#endif

#endif /* QHDefine_h */

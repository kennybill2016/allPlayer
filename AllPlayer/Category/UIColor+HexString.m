//
//  UIColor+HexString.m
//  Britain
//
//  Created by Cyril Wei on 9/27/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    unsigned int c;
    if ([hexString characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[hexString substringFromIndex:1]] scanHexInt:&c];
    } else {
        [[NSScanner scannerWithString:hexString] scanHexInt:&c];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0f green:((c & 0xff00) >> 8)/255.0f blue:(c & 0xff)/255.0f alpha:alpha];
}

@end

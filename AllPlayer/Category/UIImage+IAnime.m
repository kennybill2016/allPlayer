//
//  UIImage+IAnime.m
//  AllPlayer
//
//  Created by lijinwei on 2018/1/29.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import "UIImage+IAnime.h"

@implementation UIImage (IAnime)

+(UIImage *)initWithColor:(UIColor*)color rect:(CGRect)rect{
    CGRect imgRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIGraphicsBeginImageContextWithOptions(imgRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, imgRect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
+(UIImage *)initwithRgba:(CGFloat*)rgba rect:(CGRect)rect{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace,rgba);
    UIColor *color = [[UIColor alloc]initWithCGColor:colorRef];
    CGColorRelease(colorRef);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage initWithColor:color rect:rect];
}

@end

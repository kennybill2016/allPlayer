//
//  UIButton+Category.m
//  QihooQRCode
//
//  Created by lijinwei on 2017/3/10.
//  Copyright © 2017年 赵天福. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)

- (void) setHighlightedImageWithName:(NSString *)imageName {
    UIImage* imageBtn = [UIImage imageNamed:imageName];
    UIGraphicsBeginImageContextWithOptions(imageBtn.size, 0, [UIScreen mainScreen].scale);
    [[UIColor clearColor] set];
    UIRectFill(CGRectMake(0, 0, imageBtn.size.width, imageBtn.size.height));
    [imageBtn drawInRect:CGRectMake(0, 0, imageBtn.size.width, imageBtn.size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage* highlightedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
}

@end

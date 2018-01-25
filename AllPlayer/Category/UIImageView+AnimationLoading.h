//
//  UIImageView+AnimationLoading.h
//  hong5
//
//  Created by 赵天福 on 2017/2/15.
//  Copyright © 2017年 com.hong5.ios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SDWebImageCompletionBlock)(UIImage *image, NSURL *imageURL);

@interface UIImageView (AnimationLoading)

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animation:(BOOL)isAnimation;
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animation:(BOOL)isAnimation completed:(SDWebImageCompletionBlock)completedBlock;

@end

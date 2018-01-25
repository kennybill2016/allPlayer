//
//  UIImageView+AnimationLoading.m
//  hong5
//
//  Created by 赵天福 on 2017/2/15.
//  Copyright © 2017年 com.hong5.ios. All rights reserved.
//

#import "UIImageView+AnimationLoading.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (AnimationLoading)

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animation:(BOOL)isAnimation;
{
    if (isAnimation) {
        [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (cacheType == SDImageCacheTypeNone) {
                self.alpha = 0;
                [UIView animateWithDuration:0.25f
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.alpha = 1.0f;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
        }];
    } else {
        [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
    }
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animation:(BOOL)isAnimation completed:(SDWebImageCompletionBlock)completedBlock
{
    
    if (isAnimation) {
        [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageAvoidAutoSetImage progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (completedBlock&&image) {
                completedBlock(image, url);
            }
            
            if (cacheType == SDImageCacheTypeNone) {
                self.alpha = 0;
                [UIView animateWithDuration:0.8f
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.alpha = 1.0f;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
        }];
    } else {
        [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageAvoidAutoSetImage progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (completedBlock&&image) {
                completedBlock(image, imageURL);
            }
        }];
    }
}


@end

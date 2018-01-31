//
//  VideoInfo.h
//  AllPlayer
//
//  Created by lijinwei on 2018/1/25.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoInfo : NSObject

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *size;

- (NSComparisonResult)nameCompare:(VideoInfo *)info;
- (NSComparisonResult)compare:(VideoInfo *)info;

@end

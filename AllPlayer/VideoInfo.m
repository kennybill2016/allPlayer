//
//  VideoInfo.m
//  AllPlayer
//
//  Created by lijinwei on 2018/1/25.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import "VideoInfo.h"

@implementation VideoInfo

- (NSComparisonResult)nameCompare:(VideoInfo *)info {
    return [self.name compare:info.name];
}

- (NSComparisonResult)compare:(VideoInfo *)info {
    return [self.name compare:info.name];
}

@end

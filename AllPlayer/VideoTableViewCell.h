//
//  VideoTableViewCell.h
//  AllPlayer
//
//  Created by lijinwei on 2018/1/25.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoInfo.h"

@interface VideoTableViewCell : UITableViewCell

- (void)drawCellWithData:(VideoInfo *)info;

@end

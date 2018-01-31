//
//  VideoTableViewCell.m
//  AllPlayer
//
//  Created by lijinwei on 2018/1/25.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "UIImageView+AnimationLoading.h"

@interface VideoTableViewCell ()
{
    UILabel     *_titleL;
    UILabel     *_sizeL;
    UIImageView *_iconImg;
    UILabel     *_timeL;
}
@end

@implementation VideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        _iconImg = [[UIImageView alloc] init];
        _iconImg.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:_iconImg];
        [_iconImg setImage:[UIImage imageNamed:@"play_load"]];
        [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10.0f);
            make.left.equalTo(self.contentView).offset(10.0f);
            make.height.mas_offset(70.0f);
            make.width.mas_offset(120.0f);
        }];
        
        _titleL = [[UILabel alloc] init];
        _titleL.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00];
        _titleL.font = [UIFont fontWithName:kFontDefaultType size:16.0f];
        [self.contentView addSubview:_titleL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10.0f);
            make.left.equalTo(_iconImg.mas_right).offset(10.0f);
            make.right.equalTo(self.contentView).offset(10.0f);
        }];
        
        _sizeL = [[UILabel alloc] init];
        _sizeL.numberOfLines = 0;
        _sizeL.textColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.00];
        _sizeL.font = [UIFont fontWithName:kFontDefaultType size:13.0f];
        [self.contentView addSubview:_sizeL];
        [_sizeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleL.mas_left);
            make.bottom.equalTo(_iconImg.mas_bottom);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = UICOLOR_ARGB(0xFFF0F0F0);
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.top.equalTo(self.contentView.mas_bottom).offset(-0.5f);
            make.height.mas_offset(0.5f);
        }];
        
    }
    return self;
}

- (void)drawCellWithData:(VideoInfo *)info
{
    _titleL.text = [NSString stringWithFormat:@"%@", info.name];
    _sizeL.text = [NSString stringWithFormat:@"%@", info.size];
    
    [_iconImg setImage:[UIImage imageWithContentsOfFile:info.icon]];
}

@end

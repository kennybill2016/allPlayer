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
        
        _titleL = [[UILabel alloc] init];
        _titleL.textColor = [UIColor colorWithHexString:@"#888999" alpha:1.0f];
        _titleL.font = [UIFont fontWithName:kFontDefaultType size:13.0f];
        [self.contentView addSubview:_titleL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(16.0f);
            make.left.equalTo(self.contentView).offset(20.0f);
        }];
        
        _sizeL = [[UILabel alloc] init];
        _sizeL.numberOfLines = 0;
        _sizeL.textColor = [UIColor colorWithHexString:@"#333444" alpha:1.0f];
        _sizeL.font = [UIFont fontWithName:kFontDefaultType size:13.0f];
        [self.contentView addSubview:_sizeL];
        [_sizeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_titleL);
            make.left.equalTo(_titleL.mas_right).offset(10.0f);
        }];
        
        _iconImg = [[UIImageView alloc] init];
        _iconImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_iconImg];
        [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_titleL);
            make.height.mas_offset(18.0f);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.top.equalTo(_sizeL.mas_bottom).offset(14.0f);
            make.height.mas_offset(0.5f);
        }];
        
    }
    return self;
}

- (void)drawCellWithData:(VideoInfo *)info
{
    _titleL.text = [NSString stringWithFormat:@"%@", info.name];
    _sizeL.text = [NSString stringWithFormat:@"%@", info.size];
    
    CGRect rect = [_titleL.text boundingRectWithSize:CGSizeMake(260, 20.0f) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
    
    [_sizeL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleL);
        make.left.equalTo(_titleL.mas_right).offset(10.0f);
        make.width.mas_offset(kScreenWidth - 60.0f - rect.size.width);
    }];
    
    CGRect contentRect = [_sizeL.text boundingRectWithSize:CGSizeMake(kScreenWidth - 60.0f - rect.size.width, 1120.0f) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
    
    [_iconImg sd_setImageWithURL:[NSURL URLWithString:info.icon]
                placeholderImage:nil
                       animation:YES
                       completed:^(UIImage *image, NSURL *imageURL) {
                           if(image) {
                               [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
                                   make.left.equalTo(_titleL.mas_right).offset(20.0f + contentRect.size.width);
                                   make.centerY.equalTo(_titleL).offset(1.0f);
                                   make.height.mas_offset(18.0f);
                                   make.width.mas_offset(18.0f*image.size.width/image.size.height);
                               }];
                               _iconImg.image = image;
                           }
                       }];
}

@end

//
//  ViewController.m
//  AllPlayer
//
//  Created by lijinwei on 2018/1/24.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import "ViewController.h"
#import "SGWiFiUploadManager.h"
#import "VideoTableViewCell.h"
#import "VideoInfo.h"
#import "PlayerViewController.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UITableViewDelegate, UITableViewDataSource,SGWiFiUploadManagerDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *photoView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIProgressView *diskProgressView;
@property (nonatomic, strong) UILabel *diskLabel;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *videoArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UICOLOR_ARGB(0xFFFFFFFF);
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    [self initTopView];
    [self initPhotoView];
    [self initStatusView];
    [self initEmptyView];
    [self initContentView];

    SGWiFiUploadManager *mgr = [SGWiFiUploadManager sharedManager];
    mgr.delegate = self;
    [self loadFileFinish];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getDiskFreeSpace];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void) initTopView {
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44+20)];
    self.topView.backgroundColor = UICOLOR_ARGB(0xFF191919);
    [self.view addSubview:self.topView];
    
    [self initLeftBtn];
    [self initRightBtn];
}

- (void) initPhotoView {
    self.photoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topView.top+self.topView.height, kScreenWidth, 60)];
    self.photoView.backgroundColor = UICOLOR_ARGB(0xFFFFFFFF);
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setFrame:CGRectMake(0, 0, self.photoView.width, self.photoView.height)];
    [photoBtn addTarget:self action:@selector(actionPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.photoView addSubview:photoBtn];
    
    UIImageView* logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_logo"]];
    logoImageView.frame = CGRectMake(10, 10, 30, 30);
    [self.photoView addSubview:logoImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(logoImageView.left+logoImageView.width+10, 15, 160, 20)];
    label.font = [UIFont systemFontOfSize: 16];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = UICOLOR_ARGB(0xff333333);
    label.text = @"观看相册视频";
    [self.photoView addSubview: label];
    
    UIImageView* arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_arrow"]];
    arrowView.frame = CGRectMake(kScreenWidth-35, 5, 35, 40);
    [self.photoView addSubview:arrowView];
    
    UIView* sepView = [[UIView alloc] initWithFrame:CGRectMake(0, self.photoView.height-10, kScreenWidth, 10)];
    sepView.backgroundColor = UICOLOR_ARGB(0xFFF0F0F0);
    
    [self.photoView addSubview:sepView];
    [self.view addSubview:self.photoView];
}

- (void) initLeftBtn {
    UIImage* imageBtn = [UIImage imageNamed:@"nav_logo"];
    UIImageView* imageLogo = [[UIImageView alloc] initWithImage:imageBtn];
    [self.topView addSubview:imageLogo];
    
    [imageLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset((10.0f));
        make.height.mas_offset((22.0f));
        make.width.mas_offset((27.0f));
        make.top.mas_offset((31.0f));
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(37+6, 32, 180, 20)];
    label.font = [UIFont systemFontOfSize: 20];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:0.13 green:0.74 blue:0.14 alpha:1.00];
    label.text = @"全能播放器";
    [self.topView addSubview: label];
}

- (void)initRightBtn {
    UIImage* imageBtn = [UIImage imageNamed:@"nav_download"];
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, imageBtn.size.width, imageBtn.size.height)];
    [rightButton setImage:imageBtn forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"nav_download_h"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self
                    action:@selector(actionTouchUploadButton)
          forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:rightButton];
    
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset((self.view.width-10.0f-35.0f-44.0f));
        make.height.mas_offset((44.0f));
        make.width.mas_offset((44.0f));
        make.top.mas_offset((24.0f));
    }];
    
    UIImage* imageMore = [UIImage imageNamed:@"nav_more"];
    UIButton* moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:imageMore forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"nav_more_h"] forState:UIControlStateHighlighted];
    [moreButton addTarget:self
                   action:@selector(moreBtnAction)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.height.mas_offset((49.0f));
        make.width.mas_offset((35.0f));
        make.top.mas_offset((20.0f));
    }];
}

- (void)initContentView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.0f];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_photoView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-18.0f);
    }];
    _tableView.rowHeight = 90.0f;
//    _tableView.estimatedRowHeight = 90.0f;
    [_tableView registerClass:[VideoTableViewCell class] forCellReuseIdentifier:@"videoCell"];
}

- (void)initEmptyView {
    _emptyView = [[UIView alloc] init];
    [self.view addSubview:_emptyView];
    [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_photoView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-18.0f);
    }];
    
    UIView* tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    [_emptyView addSubview:tempView];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view).centerOffset(CGPointMake(0, 0));
        make.height.mas_offset((150.0f));
        make.width.mas_offset((290.0f));
    }];

     
    UIImage* imageBtn = [UIImage imageNamed:@"empty_video"];
    UIImageView* imageLogo = [[UIImageView alloc] initWithImage:imageBtn];
    [tempView addSubview:imageLogo];
    
    [imageLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_emptyView);
        make.height.mas_offset((66.0f));
        make.width.mas_offset((91.0f));
        make.top.mas_offset((0.0f));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize: 18];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.00];
    label.text = @"您还没有导入任何视频哦";
    [tempView addSubview: label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_emptyView);
        make.height.mas_offset((18.0f));
        make.width.mas_offset((260.0f));
        make.top.mas_offset(26+66);
    }];
    
    UIButton* moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton addTarget:self
                   action:@selector(actionIntroduce)
         forControlEvents:UIControlEventTouchUpInside];
    [moreButton setTitle:@"如何导入" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor colorWithRed:0.10 green:0.73 blue:0.13 alpha:1.00] forState:UIControlStateNormal];
    [tempView addSubview:moreButton];
    
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_emptyView);
        make.height.mas_offset((18.0f));
        make.width.mas_offset((200.0f));
        make.top.mas_offset(26+66+18+22);
    }];
}

- (void)initStatusView {
    self.diskProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kScreenHeight-1, kScreenWidth, 1)];
    //设置UIProgressView的线条颜色(需要转到3D图，在侧面才可以看见)
    self.diskProgressView.alpha = 1.0;
    self.diskProgressView.trackTintColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.00];
    
    //设置进度条的颜色
    self.diskProgressView.progressTintColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.00];
    self.diskProgressView.progress = 0.0;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 18.0f);
    self.diskProgressView.transform = transform;
    
    [self.view addSubview:self.diskProgressView];
    
    self.diskLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, kScreenHeight-18, 200, 18)];
    self.diskLabel.font = [UIFont systemFontOfSize: 12];
    self.diskLabel.textAlignment = NSTextAlignmentLeft;
    self.diskLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00];
    self.diskLabel.text = @"";
    [self.view addSubview: self.diskLabel];
}

#pragma mark - UITableViewDelegate&DateSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    VideoInfo* info = [_videoArray objectAtIndex:indexPath.row];
    [cell drawCellWithData:info];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayerViewController *player = [[PlayerViewController alloc] init];
    VideoInfo* info = [_videoArray objectAtIndex:indexPath.row];
    player.resoucePath = info.path;
    player.resouceName = info.name;
    
    [self.navigationController pushViewController:player animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        VideoInfo* info = [_videoArray objectAtIndex:indexPath.row];
        [[SGWiFiUploadManager sharedManager] removeObject:info];
    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)actionPhoto {
    [self actionTouchUploadButton];
}

- (void)actionTouchUploadButton
{
    SGWiFiUploadManager *mgr = [SGWiFiUploadManager sharedManager];
    BOOL success = [mgr startHTTPServerAtPort:10086];
    if (success) {
        [mgr setFileUploadStartCallback:^(NSString *fileName, NSString *savePath) {
            NSLog(@"File %@ Upload Start", fileName);
        }];
        [mgr setFileUploadProgressCallback:^(NSString *fileName, NSString *savePath, CGFloat progress) {
            NSLog(@"File %@ on progress %f", fileName, progress);
        }];
        [mgr setFileUploadFinishCallback:^(NSString *fileName, NSString *savePath) {
            NSLog(@"File Upload Finish %@ at %@", fileName, savePath);
        }];
    }
    [mgr showWiFiPageFrontViewController:self dismiss:^{
        [mgr stopHTTPServer];
    }];
}

- (void)actionIntroduce {
    
}
- (void)moreBtnAction
{
}

- (void)loadFileFinish {
    _videoArray = [[SGWiFiUploadManager sharedManager] getVideoList];
    [self.tableView reloadData];
    if(_videoArray.count>0) {
        _tableView.hidden = NO;
        _emptyView.hidden = YES;
    }
    else {
        _tableView.hidden = YES;
        _emptyView.hidden = NO;
    }
    [self getDiskFreeSpace];

}

- (void)getDiskFreeSpace {
    NSString* freeSpace = [Tools freeDiskSpaceStr];
    NSString* totalSpace = [Tools haveTotalDiskSpaceStr];
    
    CGFloat totalDisk = [[Tools totalDiskSpace] floatValue];
    CGFloat useDisk = [[Tools haveUseDiskSpace] floatValue];
    
    self.diskProgressView.progress = useDisk/totalDisk;
    self.diskLabel.text = [NSString stringWithFormat:@"总空间%@/剩余%@",totalSpace,freeSpace];
}

@end

//
//  PlayerViewController.m
//  AllPlayer
//
//  Created by lijinwei on 2018/1/29.
//  Copyright © 2018年 lijinwei. All rights reserved.
//

#import "PlayerViewController.h"
#import "ZFPlayer.h"

@interface PlayerViewController () <ZFPlayerDelegate>

@property (nonatomic,strong) ZFPlayerView *playerView;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.playerView = [[ZFPlayerView alloc] init];
    self.playerView.frame = self.view.bounds;
    [self.view addSubview:self.playerView];
    
    ///初始化控制层
    ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
    ///初始化播放模型
    ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
    playerModel.title = self.resouceName;
    playerModel.videoURL = [NSURL fileURLWithPath:self.resoucePath];
    playerModel.fatherView = self.view;
    [self.playerView playerControlView:controlView playerModel:playerModel];
    
    ///设置代理
    self.playerView.delegate = self;
    ///自动播放
    [self.playerView autoPlayTheVideo];
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

- (void)zf_playerBackAction{
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

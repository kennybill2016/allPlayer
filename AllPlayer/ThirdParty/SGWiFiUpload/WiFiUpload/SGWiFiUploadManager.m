//
//  SGWiFiUploadManager.m
//  SGWiFiUpload
//
//  Created by soulghost on 29/6/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGWiFiUploadManager.h"
#import "HYBIPHelper.h"
#import "SGHTTPConnection.h"
#import "SGWiFiViewController.h"

@interface SGWiFiUploadManager () {
    NSString *_tmpFileName;
    NSString *_tmpFilePath;
    NSMutableDictionary* _showVideoDict;
    NSMutableDictionary* _hideVideoDict;
    
    NSMutableArray* _showVideoList;
}

/*
 *  Callback Blocks
 */
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadStartBlock startBlock;
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadProgressBlock progressBlock;
@property (nonatomic, copy) SGWiFiUploadManagerFileUploadFinishBlock finishBlock;

@end

@implementation SGWiFiUploadManager

+ (instancetype)sharedManager {
    static SGWiFiUploadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

+ (NSString *)ip {
    return [HYBIPHelper deviceIPAdress];
}

- (NSString *)ip {
    return [HYBIPHelper deviceIPAdress];
}

- (UInt16)port {
    return self.httpServer.port;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    [self setupStop];
}

- (void)initialize {
    self.webPath = [[NSBundle mainBundle] resourcePath];
    self.savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.cacheImgPath = [self.cachePath stringByAppendingPathComponent:@"ImportVideoIcon"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cacheImgPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheImgPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    _showVideoDict = [NSMutableDictionary new];
    _hideVideoDict = [NSMutableDictionary new];
    NSDictionary* showVideoDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowVideoList"];
    if( showVideoDict ) {
        _showVideoDict = [NSMutableDictionary dictionaryWithDictionary:showVideoDict];
    }
    NSDictionary* hideVideoDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"HideVideoList"];
    if( hideVideoDict ) {
        _hideVideoDict = [NSMutableDictionary dictionaryWithDictionary:hideVideoDict];
    }

    NSMutableArray* array = [NSMutableArray new];
    for (NSString *key in _showVideoDict) {
        NSLog(@"key: %@ value: %@", key, _showVideoDict[key]);
        VideoInfo *info = _showVideoDict[key];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:info.path]) {
            [array addObject:info];
        }
    }
    NSArray* sortArray = [array sortedArrayUsingSelector:@selector(compare:)];
    _showVideoList = [NSMutableArray arrayWithArray:sortArray];
    
    [self loadVideoInfo];
}

- (void)checkFileChange {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray* newArray = [self getMovies];
        NSArray* sortArray = [newArray sortedArrayUsingSelector:@selector(compare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            _showVideoList = [NSMutableArray arrayWithArray:sortArray];
            [self.delegate loadFileFinish];
            [self checkFileChange];
        });
    });
}

- (void)loadVideoInfo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray* newArray = [self getMovies];
        NSArray* sortArray = [newArray sortedArrayUsingSelector:@selector(nameCompare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            _showVideoList = [NSMutableArray arrayWithArray:sortArray];
            [self.delegate loadFileFinish];
            [self checkFileChange];
        });
    });
}

- (NSMutableArray*)getVideoList {
    return _showVideoList;
}

- (BOOL)startHTTPServerAtPort:(UInt16)port {
    HTTPServer *server = [HTTPServer new];
    server.port = port;
    self.httpServer = server;
    [self.httpServer setDocumentRoot:self.webPath];
    [self.httpServer setConnectionClass:[SGHTTPConnection class]];
    NSError *error = nil;
    [self.httpServer start:&error];
    if (error == nil) {
        [self setupStart];
    }
    return error == nil;
}

- (BOOL)startHTTPServerAtPort:(UInt16)port start:(SGWiFiUploadManagerFileUploadStartBlock)start progress:(SGWiFiUploadManagerFileUploadProgressBlock)progress finish:(SGWiFiUploadManagerFileUploadFinishBlock)finish {
    self.startBlock = start;
    self.progressBlock = progress;
    self.finishBlock = finish;
    return [self startHTTPServerAtPort:port];
}

- (BOOL)isServerRunning {
    return self.httpServer.isRunning;
}

- (void)stopHTTPServer {
    [self.httpServer stop];
    [self setupStop];
}

- (void)showWiFiPageFrontViewController:(UIViewController *)viewController dismiss:(void (^)(void))dismiss {
    SGWiFiViewController *vc = [SGWiFiViewController new];
    vc.dismissBlock = dismiss;
    [viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

#pragma mark - Setup
- (void)setupStart {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadStart:) name:SGFileUploadDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinish:) name:SGFileUploadDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadProgress:) name:SGFileUploadProgressNotification object:nil];
}

- (void)setupStop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.startBlock = nil;
    self.progressBlock = nil;
    self.finishBlock = nil;
}

#pragma mark - Notification Callback
- (void)fileUploadStart:(NSNotification *)nof {
    NSString *fileName = nof.object[@"fileName"];
    NSString *filePath = [self.savePath stringByAppendingPathComponent:fileName];
    _tmpFileName = fileName;
    _tmpFilePath = filePath;
    if (self.startBlock) {
        self.startBlock(fileName, filePath);
    }
}

- (void)fileUploadFinish:(NSNotification *)nof {
    if (self.finishBlock) {
        self.finishBlock(_tmpFileName, _tmpFilePath);
    }
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    if (self.progressBlock) {
        self.progressBlock(_tmpFileName, _tmpFilePath, progress);
    }
}

#pragma mark - Block Setter
- (void)setFileUploadStartCallback:(SGWiFiUploadManagerFileUploadStartBlock)callback {
    self.startBlock = callback;
}

- (void)setFileUploadProgressCallback:(SGWiFiUploadManagerFileUploadProgressBlock)callback {
    self.progressBlock = callback;
}

- (void)setFileUploadFinishCallback:(SGWiFiUploadManagerFileUploadFinishBlock)callback {
    self.finishBlock = callback;
}

- (NSMutableArray *)getMovies{
    NSMutableArray *dataArr = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempFileList = [fileManager contentsOfDirectoryAtPath:self.savePath error:nil];
    for (NSString *pathStr in tempFileList) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",self.savePath,pathStr];
        if ([self isMovies:filePath]) {
            NSDictionary *fileDic = [fileManager attributesOfItemAtPath:filePath error:nil];
            VideoInfo *info = [[VideoInfo alloc] init];
            info.name = pathStr;
            info.path = filePath;
            info.icon =[self getVideoScreenShotImage:filePath];
            NSInteger filesize = [fileDic[@"NSFileSize"] integerValue];
            if (filesize >= 1024*1024*1024)
            {
                info.size = [NSString stringWithFormat:@"%.1fG",filesize/(1024*1024*1024.00)];
            }
            else {
                info.size = [NSString stringWithFormat:@"%.1fM",filesize/(1024*1024.00)];
            }
            [dataArr addObject:info];

        }
    }
    return dataArr;
}

- (void)removeObject:(VideoInfo *)info{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:info.path error:nil];
    
    [_showVideoList removeObject:info];
}

///判断是不是视频文件
- (BOOL)isMovies:(NSString *)path{
    return [[[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil] tracksWithMediaType:AVMediaTypeVideo] count] > 0;
}

///判断文件是否为video或者mp4(本地文件类型)
- (BOOL)isVideo:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return NO;
    }
    if ([(__bridge NSString *)(MIMEType) isEqualToString:@"video/mp4"]) {
        return YES;
    }
    return NO;
}

//将所下载的图片保存到本地
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        //ALog(@"Image Save Failed\\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        NSLog(@"文件后缀不认识");
    }
}

- (NSString*)getVideoScreenShotImage:(NSString *)filePath {
    UIImage* fileImage = [self getScreenShotImageFromVideoPath:filePath];
    NSString* imgName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    [self saveImage:fileImage withFileName:imgName ofType:@"jpg" inDirectory:self.cacheImgPath];
    return [self.cacheImgPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imgName, @"jpg"]];
}

- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return shotImage;
    
}

@end

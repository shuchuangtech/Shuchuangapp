//
//  QRCodeViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/1/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanQRCodeProtocol.h"
#include "SCUtil.h"
@interface QRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) id<ScanQRCodeProtocol> scanDelegate;
@property (strong, nonatomic) UIImageView *boundsView;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;

- (void)onLeftButton;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [naviItem setLeftBarButtonItem:leftBarButton];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"扫描二维码"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.topView = [[UIView alloc] init];
    self.bottomView = [[UIView alloc] init];
    self.leftView = [[UIView alloc] init];
    self.rightView = [[UIView alloc] init];
    [self.topView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:239.0/255.0]];
    self.topView.alpha = 0.85;
    [self.bottomView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:239.0/255.0]];
    self.bottomView.alpha = 0.85;
    [self.leftView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:239.0/255.0]];
    self.leftView.alpha = 0.85;
    [self.rightView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:239.0/255.0]];
    self.rightView.alpha = 0.85;
    
    self.boundsView = [[UIImageView alloc] init];
    [self.boundsView setImage:[UIImage imageNamed:@"qrbounds"]];
    [self.boundsView setBackgroundColor:[UIColor clearColor]];
    [self.boundsView setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [self.bgView addSubview:self.boundsView];
    
    [self.bgView addSubview:self.topView];
    [self.bgView addSubview:self.bottomView];
    [self.bgView addSubview:self.leftView];
    [self.bgView addSubview:self.rightView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat width = self.bgView.frame.size.width / 2;
    CGFloat height = width;
    [self.topView setFrame:CGRectMake(0, 0, 2.0 * width, height)];
    [self.bottomView setFrame:CGRectMake(0, 2.0 * height, 2.0 * width, self.bgView.frame.size.height - 2 * height)];
    [self.leftView setFrame:CGRectMake(0, height, width / 2, height)];
    [self.rightView setFrame:CGRectMake(3.0 * width / 2.0, height, width / 2, height)];
    [self.boundsView setFrame:CGRectMake(width / 2,  height, width, width)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startReading];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)startReading {
    NSError *error;
    //Device
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    //Output
    AVCaptureMetadataOutput *captureMetaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    [captureMetaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //Session
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }
    if ([self.captureSession canAddOutput:captureMetaDataOutput]) {
        [self.captureSession addOutput:captureMetaDataOutput];
    }
    //QRType
    CGFloat height = self.bgView.frame.size.width / 2;
    [captureMetaDataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    [captureMetaDataOutput setRectOfInterest:CGRectMake(height / self.bgView.frame.size.height, 0.25, height / self.bgView.frame.size.height, 0.5)];
    //Preview
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.bgView.layer.bounds];
    [self.bgView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    //start
    [self.captureSession startRunning];
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        [self.captureSession stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:[metadataObjects count] - 1];
        stringValue = metadataObject.stringValue;
        NSString *regex = @"SC[0-9]{10,}";
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![test evaluateWithObject:stringValue]) {
            __weak QRCodeViewController *weakSelf = self;
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"请扫描设备对应的序列号二维码" action:^(UIAlertAction *action) {
                [weakSelf.captureSession startRunning];
            }];
        }
        else {
            [self.scanDelegate getQRCodeStringValue:stringValue];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
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

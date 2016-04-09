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


- (void)onLeftButton;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"扫描二维码"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [naviItem setLeftBarButtonItem:leftBarButton];
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    
}
- (void)viewDidLayoutSubviews {
    CGFloat width = self.bgView.frame.size.width / 2;
    CGFloat height = width;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2.0 * width, height)];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 2.0 * height, 2.0 * width, self.bgView.frame.size.height - 2 * height)];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, height, width / 2, height)];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(3.0 * width / 2.0, height, width / 2, height)];
    [topView setBackgroundColor:[UIColor darkGrayColor]];
    topView.alpha = 0.85;
    [bottomView setBackgroundColor:[UIColor darkGrayColor]];
    bottomView.alpha = 0.85;
    [leftView setBackgroundColor:[UIColor darkGrayColor]];
    leftView.alpha = 0.85;
    [rightView setBackgroundColor:[UIColor darkGrayColor]];
    rightView.alpha = 0.85;
    [self.bgView addSubview:topView];
    [self.bgView addSubview:bottomView];
    [self.bgView addSubview:leftView];
    [self.bgView addSubview:rightView];
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
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"请扫描设备对应的序列号二维码" action:^(UIAlertAction *action) {
                [self.captureSession startRunning];
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

//
//  MyQRVC.m
//  ScanningView
//
//  Created by Mac on 2017/3/30.
//  Copyright © 2017年 yunniu. All rights reserved.
//

#import "MyQRVC.h"

#define SC_W [UIScreen mainScreen].bounds.size.width
#define SC_H [UIScreen mainScreen].bounds.size.height

@interface MyQRVC ()<ScanQRViewControllerDelegate>

@end

@implementation MyQRVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(35, 25, 50, 50);
    btn.titleLabel.font = [UIFont systemFontOfSize:25];
    [btn setTitle:@"<" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.delegate = self;
    //如果设备拥有闪光灯则添加闪光灯按钮和设置为自动
    if ([self.device hasFlash]) {
        //修改前必须先锁定
        [self.device lockForConfiguration:nil];
        self.device.flashMode = AVCaptureFlashModeAuto;
        [self.device unlockForConfiguration];
        UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake( CGRectGetMaxX(self.view.frame)-50, 25, 50, 50);
        [btn setImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeFlashMode:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:flashBtn];
    }
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2, 50)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = @"将二维码对准扫描框内开始识别";
    textLabel.center = CGPointMake(CGRectGetMidX(self.previewFrame), CGRectGetMaxY(self.previewFrame)+30);
    [self.view addSubview:textLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)changeFlashMode:(UIButton *)sender{
    if ([self.device hasFlash]) {
        //修改前必须先锁定
        [self.device lockForConfiguration:nil];
        if (self.device.flashMode == AVCaptureFlashModeOff) {
            self.device.flashMode = AVCaptureFlashModeOn;
            [sender setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
        } else if (self.device.flashMode == AVCaptureFlashModeOn) {
            self.device.flashMode = AVCaptureFlashModeAuto;
            [sender setImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
        } else if (self.device.flashMode == AVCaptureFlashModeAuto) {
            self.device.flashMode = AVCaptureFlashModeOff;
            [sender setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        }
        [self.device unlockForConfiguration];
    }
}

- (void)didDistinguishQRcode:(NSString *)string captureSession:(AVCaptureSession *)session{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:string preferredStyle:UIAlertControllerStyleAlert];
    __weak __typeof(self) weakself = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        [session startRunning];
        [weakself startScanningAnimation];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

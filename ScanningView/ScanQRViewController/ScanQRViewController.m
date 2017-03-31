//
//  ScanQRViewController.m
//  ScanningView
//
//  Created by Mac on 2017/3/29.
//  Copyright © 2017年 yunniu. All rights reserved.
//

#import "ScanQRViewController.h"

@interface ScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (assign,nonatomic)BOOL noCamera;//在初始化时记录设备是否有摄像头
@property (strong,nonatomic)UIImageView *scanLineView;

@end


@implementation ScanQRViewController
@synthesize previewRect = _previewRect;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化扫描
    [self initAVCaptureSession];
    //初始化扫描框视图
    [self initScanBoxImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_noCamera) {//在vc已经显示时才告知用户没有摄像头 因为viewdidload里不能弹出alert
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"该设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [_session startRunning];
        [self startScanningAnimation];
        //监听程序从后台回到前台的事件 执行动画
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startScanningAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//禁止旋屏
- (BOOL)shouldAutorotate{
    return NO;
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//初始化扫描
- (void)initAVCaptureSession{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_device) {
        _noCamera = YES;
        return;
    }
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    NSError *error ;
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    NSLog(@"input init error:%@",error.localizedDescription);
    // 把输入加载到session里
    if ([_session canAddInput:_input]){
        [_session addInput:_input];
    }
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];//设置管理输出的所在线程
    [_output setRectOfInterest:self.previewRect];//设置二维码的识别范围
    // 把输出加载到session里
    if ([_session canAddOutput:_output]){
        [_session addOutput:_output];
    }
    //设置能识别的二维码类型(必须把output加载到session后才能设置)
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code/*条形码*/];
    //预览图层
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    [self.view.layer insertSublayer:[self getMaskLayer] above:_preview];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] >0){
        //停止扫描
        [_session stopRunning];
        [self stopScanningAnimation];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *result = metadataObject.stringValue;
        if ([self.delegate respondsToSelector:@selector(didDistinguishQRcode:captureSession:)]) {
            [self.delegate didDistinguishQRcode:result captureSession:_session];
        }
    }
}
//创建四周的暗影遮罩图层
- (CALayer *)getMaskLayer{
    //底层layer
    CALayer *layer = [CALayer layer];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    layer.frame = self.view.bounds;

    //上遮罩
    CALayer *layertop = [CALayer layer];
    layertop.backgroundColor = self.maskColor.CGColor;
    layertop.frame = CGRectMake(0, 0, width, self.previewFrame.origin.y);
    //左遮罩
    CALayer *layerleft = [CALayer layer];
    layerleft.backgroundColor = self.maskColor.CGColor;
    layerleft.frame = CGRectMake(0, self.previewFrame.origin.y, self.previewFrame.origin.x, self.previewFrame.size.height);
    //右遮罩
    CALayer *layerright = [CALayer layer];
    layerright.backgroundColor = self.maskColor.CGColor;
    layerright.frame = CGRectMake(self.previewFrame.origin.x+self.previewFrame.size.width, self.previewFrame.origin.y, width-(self.previewFrame.origin.x+self.previewFrame.size.width), self.previewFrame.size.height);
    //下遮罩
    CALayer *layerdown = [CALayer layer];
    layerdown.backgroundColor = self.maskColor.CGColor;
    layerdown.frame = CGRectMake(0, self.previewFrame.origin.y+self.previewFrame.size.height,width, height-(self.previewFrame.origin.y+self.previewFrame.size.height));
    
    [layer addSublayer:layertop];
    [layer addSublayer:layerleft];
    [layer addSublayer:layerright];
    [layer addSublayer:layerdown];
    
    return layer;
}
//初始化扫描框视图
- (void)initScanBoxImageView{
    _scanBoxImageView = [[UIImageView alloc]initWithFrame:self.previewFrame];
    [_scanBoxImageView setImage:self.scanBoxImage];
    [self.view addSubview:_scanBoxImageView];
}

//开始扫描动画
- (void)startScanningAnimation{
    if (!self.scanLineView.superview) {
        [self.scanBoxImageView addSubview:self.scanLineView];
    }
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"position.y"];
    basic.duration = self.duration;
    basic.repeatCount = HUGE_VALF;
    basic.fromValue = [NSNumber numberWithFloat:self.scanLineView.frame.origin.y];
    basic.toValue = [NSNumber numberWithFloat:CGRectGetHeight(self.previewFrame)];
    [self.scanLineView.layer addAnimation:basic forKey:@"scanLine"];
    
}
//停止扫描动画
- (void)stopScanningAnimation{
    [self.scanLineView.layer removeAnimationForKey:@"scanLine"];
}

#pragma mark 懒加载
- (void)setPreviewRect:(CGRect)previewRect{
    CGFloat x = previewRect.origin.x<= 1 ? previewRect.origin.x : 1;
    CGFloat y = previewRect.origin.y<= 1 ? previewRect.origin.y : 1;
    CGFloat width = previewRect.size.width<= 1 ? previewRect.size.width : 1;
    CGFloat height = previewRect.size.height<= 1 ? previewRect.size.height : 1;
    _previewRect = CGRectMake(y, x, height, width);
}

- (CGRect)previewRect{
    if (CGRectIsEmpty(_previewRect)) {
        _previewRect = CGRectMake(0.3, 0.2, 0.4, 0.6);
    }
    return _previewRect;
}

- (CGRect)previewFrame{
    if (CGRectIsEmpty(_previewFrame)) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        _previewFrame = CGRectMake(self.previewRect.origin.y*width, self.previewRect.origin.x*height, self.previewRect.size.height*width, self.previewRect.size.width*height);
    }
    return _previewFrame;
}

- (UIColor *)maskColor{
    if (!_maskColor) {
        _maskColor = [UIColor colorWithWhite:0.1 alpha:0.4];
    }
    return _maskColor;
}

- (CGFloat)scanBoxLineWidth{
    if (_scanBoxLineWidth == 0) {
        _scanBoxLineWidth = 10.0;
    }
    return _scanBoxLineWidth;
}

- (UIColor *)scanBoxColor{
    if (!_scanBoxColor) {
        _scanBoxColor = [UIColor whiteColor];
    }
    return _scanBoxColor;
}

- (UIColor *)scanLineColor{
    if (!_scanLineColor) {
        _scanLineColor = [UIColor whiteColor];
    }
    return _scanLineColor;
}
- (float)scanLineWidth{
    if (_scanLineWidth == 0) {
        _scanLineWidth = 3.0;
    }
    return _scanLineWidth;
}
- (float)duration{
    if (_duration == 0) {
        _duration = 3.5;
    }
    return _duration;
}
- (UIImage *)scanBoxImage{
    if (!_scanBoxImage) {
        _scanBoxImage = [self getScanBox];
        _scanBoxImage = [_scanBoxImage resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25) resizingMode:UIImageResizingModeStretch];
    }
    return _scanBoxImage;
}

- (UIImageView *)scanLineView{
    if (!_scanLineView) {
        _scanLineView = [[UIImageView alloc]initWithImage:[self getScanLine]];
        CGRect r = self.scanBoxImageView.bounds;
        r.origin.x = 10;
        r.size.width -= 20;
        r.size.height = self.scanLineWidth;
        _scanLineView.frame = r;
    }
    return _scanLineView;
}


//扫描框绘图
- (UIImage *)getScanBox{
    UIGraphicsBeginImageContext(CGSizeMake(51, 51));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, self.scanBoxLineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.scanBoxColor.CGColor);
    CGContextMoveToPoint(ctx, 0, 25);
    CGContextAddLineToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 25, 0);
    
    CGContextMoveToPoint(ctx, 26, 0);
    CGContextAddLineToPoint(ctx, 51, 0);
    CGContextAddLineToPoint(ctx, 51, 25);
    
    CGContextMoveToPoint(ctx, 51, 26);
    CGContextAddLineToPoint(ctx, 51, 51);
    CGContextAddLineToPoint(ctx, 26, 51);
    
    CGContextMoveToPoint(ctx, 25, 51);
    CGContextAddLineToPoint(ctx, 0, 51);
    CGContextAddLineToPoint(ctx, 0, 26);
    CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//扫描线绘图
- (UIImage *)getScanLine{
    UIGraphicsBeginImageContext(CGSizeMake(100, 5));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, self.scanLineColor.CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, 100, 5));
    CGContextDrawPath(ctx, kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

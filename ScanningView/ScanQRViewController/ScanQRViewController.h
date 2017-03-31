//
//  ScanQRViewController.h
//  ScanningView
//
//  Created by Mac on 2017/3/29.
//  Copyright © 2017年 yunniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScanQRViewControllerDelegate <NSObject>

@optional
//识别成功时回调 session会被停止 如需继续识别需要[session startRunning]
- (void)didDistinguishQRcode:(NSString *)string captureSession:(AVCaptureSession *)session;

@end

@interface ScanQRViewController : UIViewController
/*
 * 扫描设备 (用以设置闪光灯)
 */
@property (strong,nonatomic)AVCaptureDevice * device;
/*
 * 扫描会话
 */
@property (strong,nonatomic)AVCaptureSession * session;
/*
 * 会话输入(从摄像头输入到会话)
 */
@property (strong,nonatomic)AVCaptureDeviceInput * input;
/*
 * 会话输出(从会话输出到app)
 */
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
/*
 * 扫描预览视图层
 */
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
/*
 * 识别范围 默认CGRectMake(0.2, 0.3, 0.6, 0.4) 因为识别范围的设置会翻转 所以set方法里已经做了翻转处理 这里继续以左上角为原点即可
 * 建议 2*x+width = 1; 2*y+height = 1;
 */
@property (assign,nonatomic)CGRect previewRect;
/*
 * 识别范围的真正frame 即扫描框的frame 它由previewRect决定 建议不要直接修改
 */
@property (assign,nonatomic)CGRect previewFrame;
/*
 * 四周的暗影颜色 默认[UIColor colorWithWhite:0.1 alpha:0.4]
 */
@property (strong,nonatomic)UIColor *maskColor;
/*
 * 扫描框线粗 默认10.0
 */
@property (assign,nonatomic)CGFloat scanBoxLineWidth;
/*
 * 扫描框颜色 默认whiteColor
 */
@property (strong,nonatomic)UIColor *scanBoxColor;
/*
 * 扫描线颜色 默认whiteColor
 */
@property (strong,nonatomic)UIColor *scanLineColor;
/*
 * 扫描线粗细 默认3.0
 */
@property (assign,nonatomic)float scanLineWidth;
/*
 * 扫描框图片 不设置则使用默认绘图
 */
@property (strong,nonatomic)UIImage *scanBoxImage;
/*
 * 扫描框 加载scanBoximage的imageview 可在其基础上做其它操作 frame=previewFrame
 */
@property (strong,nonatomic)UIImageView *scanBoxImageView;
/*
 * 以上属性在viewDidLoad后全部生效 建议继承该类来作拓展
 */

/*
 * 代理 识别到二维码时回调
 */
@property (weak,nonatomic)id<ScanQRViewControllerDelegate> delegate;
/*
 * 扫描动画时长 默认3.5s
 */
@property (assign,nonatomic)float duration;
/*
 * 开始扫描动画
 */
- (void)startScanningAnimation;
/*
 * 结束扫描动画
 */
- (void)stopScanningAnimation;


@end

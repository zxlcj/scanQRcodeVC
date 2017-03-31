//
//  ViewController.m
//  ScanningView
//
//  Created by Mac on 2017/3/27.
//  Copyright © 2017年 yunniu. All rights reserved.
//

#import "ViewController.h"
#import "MyQRVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(50, 50, 200, 100);
    [btn setTitle:@"扫描" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)scan{
    MyQRVC *sqrvc = [[MyQRVC alloc]init];
    sqrvc.scanBoxColor = [UIColor greenColor];
    sqrvc.scanLineColor = [UIColor greenColor];
//    sqrvc.previewRect = CGRectMake(0.2, 0.3, 0.6, 0.4);
//    sqrvc.scanBoxLineWidth = 5.0;
//    sqrvc.scanLineWidth = 6.0;
//    sqrvc.duration = 1.5;
    [self presentViewController:sqrvc animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

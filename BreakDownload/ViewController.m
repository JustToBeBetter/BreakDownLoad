//
//  ViewController.m
//  BreakDownload
//
//  Created by Mrli on 15/7/16.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import "ViewController.h"


#define kUrl @"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.0.1419920162.dmg"


@interface ViewController ()
{
    BreakPointDownload*_breakDownload;
    NSTimer *_timer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _breakDownload =[[BreakPointDownload alloc]init];
    double s=[[NSUserDefaults standardUserDefaults]doubleForKey:[kUrl MD5Hash]];
    self.downloadProggressView.progress=s;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startClick:(UIButton *)sender {
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getDownloadSpeed) userInfo:nil repeats:YES];
    }
    __weak typeof(self)mySelf=self;
    
    [_breakDownload downloadWithUrl:kUrl loadingBlock:^(BreakPointDownload *download) {
        //每下载 一段数据就会回调这个block
        //文件总大小
        double fileSize=download.TotaleFileSize/1024.0/1024.0;//转化为M
        //已经下载
        mySelf.loadFileSize=download.loadFileSize;
        //百分比
        double scale=(double)download.loadFileSize/download.TotaleFileSize;
        //进度条
        mySelf.downloadProggressView.progress=scale;
        mySelf.progressLabel.text=[NSString stringWithFormat:@"下载百分比:%.2f%%  文件总大小:%.2fM  下载速度:%.2fK/S",scale*100,fileSize,self.speed];
        //每次把进度 保存到本地
        
        [[NSUserDefaults standardUserDefaults] setDouble:scale forKey:[kUrl MD5Hash]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        if (self.downloadProggressView.progress>=1.0) {
            if (_timer) {
                [_timer invalidate];
                _timer=nil;  //下载结束终止定时器
            }
        }
    }];
    
}
-(void)getDownloadSpeed
{
    self.speed=(self.loadFileSize -self.preLoadFileSize)/1024.0;//得到小数
    //记录已经下载的
    self.preLoadFileSize=self.loadFileSize;

}
- (IBAction)stopClick:(UIButton *)sender {
    
    [_breakDownload stopDownload];
    if (_timer) {
        [_timer invalidate];//销毁终止定时器
        _timer=nil;
    }
}
@end

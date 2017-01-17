//
//  ViewController.h
//  BreakDownload
//
//  Created by Mrli on 15/7/16.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BreakPointDownload.h"
#import "NSString+Hashing.h"


@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

- (IBAction)startClick:(UIButton *)sender;

- (IBAction)stopClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProggressView;
@property (nonatomic)unsigned long long loadFileSize;
@property (nonatomic)unsigned long long preLoadFileSize;
//下载速度
@property (nonatomic)double speed;

@end


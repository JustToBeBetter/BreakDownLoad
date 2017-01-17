//
//  BreakPointDownload.h
//  BreakDownload
//
//  Created by Mrli on 15/7/16.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  有时候下载数据需要暂停 暂停后需要继续下载  这时就需要实现断点续传  如果要做断点续传  服务器和客户端都必须支持 否则不会成功
 */
//定义block 回调 告知界面下载进度
@class BreakPointDownload;
typedef void (^DownloadBlock)(BreakPointDownload*download);
@interface BreakPointDownload : NSObject<NSURLConnectionDataDelegate>
{

    NSURLConnection*_httpRequest;
}
//保存block
@property(nonatomic,copy)DownloadBlock myBlock;
//记录 文件总大小 字节大小
@property (nonatomic)unsigned long long  TotaleFileSize;
@property (nonatomic)unsigned long long   loadFileSize;
//传入一个block 下载过程中回调block告知界面 下载信息
-(void)downloadWithUrl:(NSString*)url loadingBlock:(DownloadBlock)myBlock;

-(void)stopDownload;

@end

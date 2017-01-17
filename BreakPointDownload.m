//
//  BreakPointDownload.m
//  BreakDownload
//
//  Created by Mrli on 15/7/16.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import "BreakPointDownload.h"
#import "NSString+Hashing.h"

@implementation BreakPointDownload
{

    NSFileHandle *_fileHandle;
}
-(void)downloadWithUrl:(NSString *)url loadingBlock:(DownloadBlock)myBlock
{
   
    if (_httpRequest) {
        [_httpRequest cancel];
        _httpRequest=nil;
    }
    //保存block
     self.myBlock=myBlock;
    //发送请求之前 先获取本地文件已经下载的大小 然后告知服务器从哪儿下载
    NSString*filePath=[self getFullPathWithFileUrl:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //判断文件是否存在  不存在则创建
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    //获取已下载文件大小
    NSDictionary*fileDic=[[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil];
    
    unsigned long long fileSize= fileDic.fileSize;
    //保存已经下载文件的大小
    self.loadFileSize=fileSize;
    
    //下载之前打开文件
    _fileHandle =[NSFileHandle fileHandleForWritingAtPath:filePath];
    
    
    //把文件大小告诉服务器
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //增加请求头 告知服务器从哪儿开始下载
    [request addValue:[NSString stringWithFormat:@"bytes=%llu-",fileSize] forHTTPHeaderField:@"Range"];
    
    //创建请求链接 开始异步下载
    _httpRequest=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    

}
#pragma mark -获取文件在沙盒中Documents下的全路径
-(NSString*)getFullPathWithFileUrl:(NSString*)url
{
    //把URL作为文件名  但是URL 中可能存在非法字符不能作为文件名 这时可以用md5 对文件名加密 产生一个唯一的字符串（十六进制的数字）
    
    NSString*fileName=[url MD5Hash];
    
    //获取Documents
    NSString*docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString*filePath=[docPath stringByAppendingPathComponent:fileName];
    NSLog(@"path:%@",filePath);
    return filePath;

}
#pragma mark --NSURLConnectionDataDelegate协议
//接受服务器响应
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //服务器告知客户端服务器将要发送的数据的大小
    NSHTTPURLResponse*httpRespose=(NSHTTPURLResponse*)response;
    NSLog(@"url:%@",httpRespose.URL.absoluteString);
    NSLog(@"type:%@",httpRespose.MIMEType);
    
    //计算文件总大小 =已经下载的+服务器将要发的
    
    self.TotaleFileSize=self.loadFileSize+httpRespose.expectedContentLength;
    
    
}
//接受数据过程 一段一段接收
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //下载一段写一段
    //先把文件偏移量定位到文件末尾
    [_fileHandle seekToEndOfFile];
    //写文件
    [_fileHandle writeData:data];
    //立即同步到磁盘
    [_fileHandle synchronizeFile];
    
    self.loadFileSize+=data.length;
    
    //通知界面 回调block 下载过程一直会回调
    if (self.myBlock) {
        self.myBlock(self);
    }
    
    
}
//下载成功
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self stopDownload];
    
}
//下载失败
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopDownload];

}

-(void)stopDownload
{
    if (_httpRequest) {
        [_httpRequest cancel];
        _httpRequest=nil;
    }
    [_fileHandle closeFile];
}
@end

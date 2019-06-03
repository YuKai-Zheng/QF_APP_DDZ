//
//  HttpBillResult.m
//  texas
//
//  Created by twl on 14-12-12.
//
//

#import "HttpBillResult.h"
#import "BasePay.h"
#import "IOSNative.h"
#import "IOSPay.h"
#import <UIKit/UIKit.h>
@implementation HttpBillResult
-(void)waitResult:(int) bill_id :(int) _payType
{
    self.int_bill_id = bill_id;
    self.payType = _payType;
    NSLog(@"bill_id:%d",  self.int_bill_id);
    //2.1设置请求路径
    NSString *url_request = [NSString stringWithFormat:@"http://pay.qfighting.com/bill/result?bill_id=%d", self.int_bill_id];
    url_request = [url_request stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:url_request];
    
    //   2.2创建请求对象
    //    NSURLRequest *request=[NSURLRequest requestWithURL:url];//默认就是GET请求
    //设置请求超时
    NSMutableURLRequest *request=[NSMutableURLRequest  requestWithURL:url];
    request.timeoutInterval=1200.0;
    
    //   2.3.发送请求
    //使用代理发送异步请求（通常应用于文件下载）
    NSURLConnection *conn=[NSURLConnection connectionWithRequest:request delegate:self];
    if(conn)
    {
        [conn start];
        NSLog(@"已经发出请求---");
    }
    NSLog(@"已经发出请求---");
    
}
#pragma mark- NSURLConnectionDataDelegate代理方法
/*
 *当接收到服务器的响应（连通了服务器）时会调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"接收到服务器的响应");
    //初始化数据
    self.responseData=[NSMutableData data];
}
/*
 *当接收到服务器的数据时会调用（可能会被调用多次，每次只传递部分数据）
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

/*
 *当服务器的数据加载完毕时就会调用
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:nil];
    NSNumber *ret = [dict objectForKey:@"ret"];
    //bill_id = [resDict objectForKey:@"bill_id"];
    NSString *sign = [dict objectForKey:@"sign"];
    NSLog(@"ret = %@, sign = %@",ret,sign);
    
    if (ret == nil)
    {
        [self waitResult:self.int_bill_id : self.payType];
    }
    NSString *path= @"/bill/result";
    NSString *sign_verify = [NSString stringWithFormat:@"%@|%@|%d",APP_SECRET,path, self.int_bill_id];
    NSString *result_verify = [IOSNative MD5:sign_verify];
    BOOL isequal = [sign isEqualToString:result_verify];
    if (isequal)
    {
        [IOSPay callBackLua:(0) :self.payType];
    }else{
        [IOSPay callBackLua:([ret intValue]) :self.payType];
    }
//    [self.waitProgress stopAnimating];
//    [self.waitProgress release];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",[error localizedDescription]);
    if (self) {
        [self waitResult:self.int_bill_id : self.payType];
    }
    
}

@end

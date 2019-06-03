//
//  HttpBillResult.m
//  texas
//
//  Created by twl on 14-12-12.
//
//

#import "HttpPayCallBack.h"
#import "BasePay.h"
#import "IOSNative.h"
#import "IOSPay.h"
#import <UIKit/UIKit.h>
@implementation HttpPayCallBack


-(NSString *) getData {
    
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSString alloc] initWithUTF8String:_jsondata.c_str()],@"receipt", nil];
    return [IOSPay dictToJson:jsonDict];
}

-(NSString *) getSign {
    NSString * signStr = [[NSString alloc] initWithFormat:@"%@|%@|%d|%d|%@",
                          APP_SECRET,@"/app/pay/cb",_billid,_result,[self getData]
                          ];
    // NSLog(@"signStr = %@",signStr);
    return [IOSNative MD5:signStr];
}

-(void)waitResult:(int) bill_id :(int) _payType :(std::string)jsondata :(int)ret
{
    _result = ret;
    _billid = bill_id;
    _paytype = _payType;
    _jsondata = jsondata;
    
    //NSLog(@" HttpPayCallBack -- bill_id:%d", _billid);
    //2.1设置请求路径
    
    
    //NSLog(@"hostname = %@" , _hostname);
    NSString *url_request =[NSString stringWithFormat:@"http://%@/app/pay/cb",_hostname];
    NSURL *url = [NSURL URLWithString:url_request];
    NSString *param=[NSString stringWithFormat:@"bill_id=%d&sign=%@&result=%d&error=%@&data=%@", _billid, [IOSPay urlencode:[self getSign]], _result, @"nil",[IOSPay urlencode:[self getData]] ];
    
    //   2.2创建请求对象
    //    NSURLRequest *request=[NSURLRequest requestWithURL:url];//默认就是GET请求
    //设置请求超时
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";//设置请求方法
    request.timeoutInterval=30;
    request.HTTPBody=[param dataUsingEncoding:NSUTF8StringEncoding];

    
    //   2.3.发送请求
    //使用代理发送异步请求（通常应用于文件下载）
    NSURLConnection *conn=[NSURLConnection connectionWithRequest:request delegate:self];
    if(conn)
    {
        [conn start];
        NSLog(@" HttpPayCallBack 已经发出请求---");
    }
    
}
#pragma mark- NSURLConnectionDataDelegate代理方法
/*
 *当接收到服务器的响应（连通了服务器）时会调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@" HttpPayCallBack 接收到服务器的响应");
    self.responseData=[NSMutableData data];
}
/*
 *当接收到服务器的数据时会调用（可能会被调用多次，每次只传递部分数据）
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     NSLog(@" HttpPayCallBack 接收到服务器的数据");
    [_responseData appendData:data];
}

/*
 *当服务器的数据加载完毕时就会调用
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@" httpPayCallBack connectionDidFinishLoading ---");
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:nil];
    
    NSNumber *ret = [dict objectForKey:@"ret"];
    NSString *error = [dict objectForKey:@"error"];
    //NSLog(@"ret = %@, sign = %@",ret,error);
    
    if (ret == nil)
    {
        NSLog(@"-------服务器没有得到想要结果 ----- ,重新发送请求 !!");
        [self waitResult:_billid :_paytype :_jsondata :_result];
    }else if ( [ret intValue] == 0) {
        [IOSPay callBackLua:0 :_paytype];
    }else{
        [IOSPay callBackLua:1000 :_paytype];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@" 请求错误 %@",[error localizedDescription]);
    
    if (self) {
        [self waitResult:_billid :_paytype :_jsondata :_result];
    }
    
}

-(void) setHostName:(NSString *)host{
    _hostname = [[NSString alloc] initWithString:host];
}

@end

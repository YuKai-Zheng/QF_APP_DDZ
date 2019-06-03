#import "ImagePostHelper.h"

#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

@implementation ImagePostHelper

+ (NSData *)getImageData:(NSString *)path {
    NSData* data;
    if(path){
        UIImage *image=[UIImage imageWithContentsOfFile:path];
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
    }
    return data;
}

+ (NSString *)postRequestWithURL: (NSString *)url  // IN
                      postParems: (NSMutableDictionary *)postParems // IN
                         picInfo: (NSArray *)picInfo
                        luacb:(int)luacb
{
    
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableData *myRequestData=[NSMutableData data];
    //http body的字符串
    
    NSArray *keys= [postParems allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        NSMutableString *body=[[NSMutableString alloc]init];
        NSString *key=[keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (NSDictionary * pic in picInfo) {
        NSMutableString *body=[[NSMutableString alloc]init];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",[pic objectForKey:@"name"],[pic objectForKey:@"filename"]];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:[self getImageData:[pic objectForKey:@"path"]]];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    [request setTimeoutInterval:60.f];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString* status = @"-1"; // 默认失败
        if ( [data length] > 0 && !connectionError ) { // 成功
            status = @"1";
        }
        if (luacb > 0) {
            cocos2d::LuaBridge::pushLuaFunctionById(luacb);
            cocos2d::LuaBridge::getStack()->pushString([status UTF8String]);
            cocos2d::LuaBridge::getStack()->executeFunction(1);
            cocos2d::LuaBridge::releaseLuaFunctionById(luacb);
        }
    }];
    return nil;
}

+ (NSString *)requestApplyAuth: (NSString *)url  // IN
                      postParems: (NSMutableDictionary *)postParems // IN
                         picInfo: (NSArray *)picInfo
                        luacb:(int)luacb
{
    
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    NSMutableData *myRequestData=[NSMutableData data];
    //http body的字符串
    
    NSArray *keys= [postParems allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        NSMutableString *body=[[NSMutableString alloc]init];
        NSString *key=[keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (NSDictionary * pic in picInfo) {
        NSMutableString *body=[[NSMutableString alloc]init];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",[pic objectForKey:@"name"],[pic objectForKey:@"filename"]];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:[self getImageData:[pic objectForKey:@"path"]]];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    [request setTimeoutInterval:60.f];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString* status;
        if ( [data length] > 0 && !connectionError ) { // 成功
            status = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        } else {
            status = nil;
        }
        if (luacb > 0) {
            cocos2d::LuaBridge::pushLuaFunctionById(luacb);
            cocos2d::LuaBridge::getStack()->pushString([status UTF8String]);
            cocos2d::LuaBridge::getStack()->executeFunction(1);
            cocos2d::LuaBridge::releaseLuaFunctionById(luacb);
        }
    }];
    return nil;
}
@end
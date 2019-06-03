//
//  ZYWebView_iOS.m
//  CCXWebview
//
//  Created by Vincent on 12-11-27.
//  Copyright (c) 2012 go3k.org. All rights reserved.
//

#import "ZYWebView_iOS.h"
#import <UIKit/UIKit.h>
#include "CCLuaBridge.h"

using namespace cocos2d;
@implementation ZYWebView_iOS



- (void)showWebView_x:(float)x y:(float)y width:(float) width height:(float)height
{
    if (!m_webview)
    {
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        if (!window) return;
        
        float scale = [[UIScreen mainScreen] scale];
        x /= scale; y /= scale; width /= scale; height /= scale;
        
        m_webview = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, width , height)];
        [m_webview setDelegate:self];
        m_webview.scrollView.bounces = NO;
        
        UIViewController * _rootController ;
        if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
        {
           
            NSArray* array=[[UIApplication sharedApplication]windows];
            UIWindow* win=[array objectAtIndex:0];
            
            UIView* ui=[[win subviews] objectAtIndex:0];
            _rootController = (UIViewController*)[ui nextResponder];
        }
        else
        {
            _rootController =[[[UIApplication sharedApplication] keyWindow ] rootViewController];
        }
        
        [_rootController.view addSubview:m_webview];
        [m_webview release];
        
        
        
        
        
        m_webview.backgroundColor = [UIColor clearColor];
        m_webview.opaque = NO;
        
        for (UIView *aView in [m_webview subviews])  
        { 
            if ([aView isKindOfClass:[UIScrollView class]])  
            { 
                UIScrollView* scView = (UIScrollView *)aView;
                
                // 是否显示右侧的滚动条 （水平的类似）
                // set Vertical Scroll bar visible
//                [(UIScrollView *)aView setShowsVerticalScrollIndicator:NO];
                [scView setShowsHorizontalScrollIndicator:NO];
//                scView.bounces = NO;
                
                for (UIView *shadowView in aView.subviews)  
                {
                    if ([shadowView isKindOfClass:[UIImageView class]]) 
                    {
                        // 隐藏上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                        // hide black background when webpage is out of border.
                        shadowView.hidden = YES;
                    } 
                } 
            } 
        }
    }
}

- (void)updateURL:(const char*)url
{
    NSString *request = [NSString stringWithUTF8String:url];
    [m_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request] 
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                        timeoutInterval:60]];
}

- (void)removeWebView
{
    if (m_webview)
    {
        [m_webview removeFromSuperview];
        m_webview = NULL;
    }
}

#pragma mark - WebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!isFirstLoadWeb)
    {
        isFirstLoadWeb = YES;
    }
    else
    {
        return;
    }
    NSLog(@" -- webViewDidStartLoad --");
    [self callLuaFunc:@"start"];

    float scale = [[UIScreen mainScreen] scale];
    CGRect rct = CGRectMake(30/scale, 15/scale, 70/scale, 67/scale);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rct];
    [m_webview addSubview:imageView];
    
   
    imageView.backgroundColor = [UIColor clearColor];
    [imageView setImage:[UIImage imageNamed:@"__back_btn.png"]];
//    imageView.backgroundColor = [UIColor redColor];
    imageView.userInteractionEnabled = YES;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0,0,70/scale, 70/scale);
    [imageView addSubview:btn];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (isFirstLoadWeb)
    {
        isFirstLoadWeb = NO;
    }
    else
    {
        return;
    }
    NSLog(@" -- webViewDidFinishLoad --");
    [self callLuaFunc:@"done"];
    LuaBridge::releaseLuaFunctionById(_luacb);
    _luacb = -1;
    
     [webView setBackgroundColor: [UIColor darkGrayColor]];
}

- (void)click
{
    if (_luacb==-1 && _luacb2==-1) {
        [self removeWebView];
        return;
    }
    [self callLuaFunc:@"done"];
    LuaBridge::releaseLuaFunctionById(_luacb);

    LuaBridge::pushLuaFunctionById(_luacb2);
    LuaBridge::getStack()->pushString("close");
    LuaBridge::getStack()->executeFunction(1);
    LuaBridge::releaseLuaFunctionById(_luacb2);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@" -- didFailLoadWithError --");
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        NSLog(@"%@",[error localizedFailureReason]);
        NSLog(@"%@",[error localizedRecoverySuggestion]);
    }
    
    [self callLuaFunc:@"error"];
    LuaBridge::releaseLuaFunctionById(_luacb);
    _luacb = -1;
}

- (void)setLuaCB:(int)cb {
    _luacb = cb;
}

- (void) setLuaCB2:(int)cb {
    _luacb2 = cb;
}
- (void)callLuaFunc:(NSString *)status {
    if (_luacb > 0) {
        LuaBridge::pushLuaFunctionById(_luacb);
        LuaBridge::getStack()->pushString([status UTF8String]);
        LuaBridge::getStack()->executeFunction(1);
    }
}

@end

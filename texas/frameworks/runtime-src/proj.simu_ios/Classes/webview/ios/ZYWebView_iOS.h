//
//  ZYWebView_iOS.h
//  CCXWebview
//
//  Created by Vincent on 12-11-27.
//  Copyright (c) 2012 go3k.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYWebView_iOS : NSObject <UIWebViewDelegate>
{
    UIWebView* m_webview;
    int _luacb;
    int _luacb2;
}


- (void)showWebView_x:(float)x y:(float)y width:(float) widht height:(float)height;
- (void)setLuaCB : (int) cb;
- (void)setLuaCB2 : (int) cb;
- (void)updateURL:(const char*)url;

- (void) removeWebView;

- (void) callLuaFunc : (NSString *) status;
- (void) click ;
@end

//
//  UnityAtOnceGoWeb.m
//  texas
//
//  Created by qf on 17/3/11.
//
//

#import "UnityAtOnceGoWeb.h"
#import "PartyConstants.h"

#import "webview/ZYWebView.h"
#include "cocos2d.h"

using namespace std;

@implementation UnityAtOnceGoWeb

-(void) zny_openUrl: (NSString*) url {
    NSURL * urlStr = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:urlStr]) {
        [[UIApplication sharedApplication] openURL:urlStr];
    }
    else {
        // 这里为了简单直接使用系统浏览器打开，可以继承重写用 WebView 加载，体验更好
        auto framesize = cocos2d::Director::getInstance()->getWinSize();
        ZYWebView::getInstance()->showWebView([url UTF8String], 0, 0, framesize.width, framesize.height,-1,-1);
    }
}

-(void) zny_openUrl: (NSString*) url channel:(NSString*)partyChannelType {
    if (partyChannelType == ATONCEGO_CHANNEL_BABA) {
        NSURL * urlStr = [NSURL URLWithString:url];
        if ([[UIApplication sharedApplication] canOpenURL:urlStr]) {
            [[UIApplication sharedApplication] openURL:urlStr];
        }
        else {
            // 这里为了简单直接使用系统浏览器打开，可以继承重写用 WebView 加载，体验更好
            auto framesize = cocos2d::Director::getInstance()->getWinSize();
            ZYWebView::getInstance()->showWebView([url UTF8String], 0, 0, framesize.width, framesize.height,-1,-1);
        }
    }
    else {
        // 这里为了简单直接使用系统浏览器打开，可以继承重写用 WebView 加载，体验更好
        auto framesize = cocos2d::Director::getInstance()->getWinSize();
        ZYWebView::getInstance()->showWebView([url UTF8String], 0, 0, framesize.width, framesize.height,-1,-1);
    }
}

@end

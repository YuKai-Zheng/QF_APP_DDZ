//
//  SDKMacros.h
//  texas
//
//  Created by Jiangliwu on 14/12/9.
//
//

#ifndef texas_SDKMacros_h
#define texas_SDKMacros_h

#include <functional>
#include <string>

#define SDK_HAIMA 23 //相当于支付 类型 billType
#define SDK_APPSTORE 0 //相当于支付 类型 billType
#define SDK_BLANK -1
#define SDK_XXXXX 2
typedef std::function< void(int,std::string) > paycb;

#endif

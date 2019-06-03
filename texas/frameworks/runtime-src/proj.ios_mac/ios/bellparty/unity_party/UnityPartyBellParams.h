#import <Foundation/Foundation.h>


@interface UnityPartyBellParams : NSObject

@property (nonatomic, assign) int bellType;         // 支付类型
@property (nonatomic, copy) NSString* userID;       // 用户ID
@property (nonatomic, copy) NSString* itemID;       // 物品id
@property (nonatomic, assign) double amt;           // 金额
@property (nonatomic, copy) NSString* channel;      // 渠道
@property (nonatomic, assign) int appVersion;       // 应用版本号
@property (nonatomic, copy) NSString* mapBellID;    // 映射的bill_id，方便查找对应的
@property (nonatomic, assign) int ref;              // 触发支付的位置
@property (nonatomic, copy) NSString* passInfo;     // 原样透传的信息

@property (nonatomic, strong) NSMutableDictionary* extra;   // 预留的额外字段，给支付SDK使用，不会传递到支付服务器


-(NSMutableDictionary*) zny_toDict;

@end

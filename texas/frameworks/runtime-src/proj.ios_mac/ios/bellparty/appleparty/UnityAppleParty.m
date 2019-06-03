//
//  UnityAppleParty.m
//  unity_applepay
//
//  Created by 朱念洋 on 17/2/25.
//  Copyright © 2017年 dantezhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityAppleParty.h"
#import "UnityPartyConstants.h"
#import "UnityApplePartySKProductsRequest.h"

@interface UnityAppleParty()

// 存储delegate，否则面临被释放的危险
@property (nonatomic, strong) NSMutableSet* productDelegateSet;
// bill_id->onResult的映射表
@property (nonatomic, strong) NSMutableDictionary* onResultDict;

@end

@implementation UnityAppleParty

-(id)init: (NSString*)host source: (NSString*)source secret: (NSString*) secret
{
    if (self = [super init]) {
        _unityParty = [[UnityParty alloc] init: host source:source secret:secret];
        self.productDelegateSet = [[NSMutableSet alloc] init];
        self.onResultDict = [[NSMutableDictionary alloc] init];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    }
    return self;
}

-(void)zny_party: (UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    
    if (![SKPaymentQueue canMakePayments]) {
        if (onResult) {
            onResult(PARTY_RESULT_FAIL, 0);
        }
        return;
    }
    NSString* itemCode = [bellParams.extra objectForKey:@"item_code"];
    if (!itemCode) {
        onResult(PARTY_RESULT_FAIL, 0);
        return;
    }
    
    NSArray *products = [[NSArray alloc] initWithObjects:itemCode, nil];
    NSSet *set = [NSSet setWithArray:products];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    UnityApplePartySKProductsRequest* skProductsRequestDelegate = [[UnityApplePartySKProductsRequest alloc] init: self bellParams:bellParams
                                                                                            onResult: onResult];
    // 防止释放，因为底下的delegate是weak
    [self.productDelegateSet addObject:skProductsRequestDelegate];
    
    request.delegate = skProductsRequestDelegate;

    
    [request start];
}

-(void) zny_allocBell: (SKProduct*)product bellParams:(UnityPartyBellParams*)bellParams
         onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    [self.unityParty zny_allocBell:bellParams onSucc:^(int bellID) {
        [self zny_callSDK:product bellID:bellID bellParams:bellParams onResult:onResult];
    } onFail:^(int result) {
        if (onResult) {
            onResult(result, 0);
        }
    }];
}

-(void) zny_callSDK: (SKProduct*)product bellID: (int) bellID bellParams:(UnityPartyBellParams*)bellParams
       onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    // 要记得清除
    [self.onResultDict setObject:onResult forKey:[NSString stringWithFormat:@"%d", bellID]];
    
    SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = [NSString stringWithFormat:@"%d", bellID];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void) zny_setBellResult: (int)bellID result: (int)result data: (NSDictionary*)data
             onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    [self.unityParty zny_setBellResult:bellID result:result data:data
                          onSucc:^() {
                              if (onResult) {
                                  onResult(0, bellID);
                              }
                          }
                          onFail:^(int result) {
                              if (onResult) {
                                  onResult(result, bellID);
                              }
                          }];
}

-(void) zny_onGetProductResult: (id)delegate product:(SKProduct*)product bellParams:(UnityPartyBellParams*)bellParams
            onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    
    // 释放
    [self.productDelegateSet removeObject:delegate];
    
//    NSLog(@"[myProduct count]= %d", [product count]);
    if (!product) {
        onResult(PARTY_RESULT_FAIL, 0);
        return;
    }

    [self zny_allocBell:product bellParams:bellParams onResult:onResult];
}

//交易结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            //交易完成
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"SKPaymentTransactionStatePurchased");
                [self zny_completeTransaction:transaction];
                break;
            }
            //交易失败
            case SKPaymentTransactionStateFailed: {
                NSLog(@"SKPaymentTransactionStateFailed");
                [self zny_failedTransaction:transaction];
                break;
            }
            //已经购买过该商品
            case SKPaymentTransactionStateRestored: {
                NSLog(@"SKPaymentTransactionStateRestored");
                [self zny_restoreTransaction:transaction];
            }
            //商品添加进列表
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            }
            default: {
                NSLog(@"transactionState: %ld", transaction.transactionState);
                break;
            }

        }
    }
}

- (void) zny_completeTransaction: (SKPaymentTransaction *)transaction {
    // 本来想在onResult里面来finish，但是想想其实如果网络出问题，一样会触发超时导致finish。
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // 之前设置进去的bill_id
    NSString* bellID = transaction.payment.applicationUsername;
    
    UNITY_PARTY_RESULT_CALLBACK onResult = [self.onResultDict objectForKey:bellID];
    // 删掉
    [self.onResultDict removeObjectForKey:bellID];

    NSMutableDictionary* dataDict = [[NSMutableDictionary alloc] init];
    
    // 这是还是用老的方法在处理，因为新方法感觉和当前transaction没有强绑定关系，可能会串单？
    NSString* receipt = [transaction.transactionReceipt
                         base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    // 新方法 [[NSBundle mainBundle] appStoreReceiptURL] 会导致签名验证不对，服务器发现传过去的数据都不一致，很奇怪
    /*
    NSString *receipt2 = [[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]
                         base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    */

    [dataDict setObject:receipt forKey:@"receipt"];
    
    [self zny_setBellResult:[bellID intValue]
                 result:0 data:dataDict onResult:onResult
     ];
    
}

- (void) zny_failedTransaction: (SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSString* bellID = transaction.payment.applicationUsername;
    UNITY_PARTY_RESULT_CALLBACK onResult = [self.onResultDict objectForKey:bellID];
    
    [self.onResultDict removeObjectForKey:bellID];

    if (transaction.error.code == SKErrorPaymentCancelled)  {
        if (onResult) {
            onResult(PARTY_RESULT_USER_CANCEL, [bellID intValue]);
        }
    }
    else {
        if (onResult) {
            onResult(PARTY_RESULT_FAIL, [bellID intValue]);
        }
    }

}

- (void)zny_restoreTransaction:(SKPaymentTransaction *)transaction {
    // 与支付成功走同样的逻辑就好，反正服务器端会验证
    // 这样中途断网起码可以恢复支付
    [self zny_completeTransaction:transaction];
}

@end

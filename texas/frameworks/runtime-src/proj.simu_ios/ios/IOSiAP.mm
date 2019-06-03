//
//  IapLayer.m
//
//  Created by Himi on 11-5-25.
//  Copyright 2011年 李华明 . All rights reserved.
//

#import "IOSiAP.h"


@implementation IOSiAP

-(id)init
{
    if ((self = [super init])) {
        //----监听购买结果
        
        _perfix = @"";
        NSString *  identify= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] ;
        if( [identify isEqual:@"com.qufan.thtexas"]){
            _perfix = @"com.qufan.thtexas.";
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        _requestingData = false;
        _products.clear();
        _buyindex = -1;
    }
    return self;
}

-(int) getBuyIndex:(NSString *)code
{
    NSLog(@" -----   getcode ----- %@" ,code );
    NSString * fullname = [[NSString alloc] initWithFormat:@"%@%@",_perfix,code];
    NSLog(@" -----   getBuyIndex ----- %@" ,fullname );
    for (int i = 0 ; i < _products.size(); i++) {
        SKProduct * p = _products[i];
        if ( [p.productIdentifier isEqual:fullname]) {
            return i;
        }
    }
    return -1;
}
-(void)buy : (NSString *  )code
{
    // index可能为0的
    if (_buyindex >= 0) {
        NSLog(@" 正在购买中 ");
        return;
    }
    
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"设备允许程序内付费购买");
    }
    else
    {
        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"无法购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
        return;
        
    }
    
    
    
    _buyindex = [self getBuyIndex:code];
    NSLog(@" _ buyindex = %d",_buyindex);
    if (_buyindex < 0 ) {
        return;
    }
    
    
    if (_products.size() > 0) {
        [self pay];
    }else{
        [self RequestProductData];
    }
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

-(void)RequestProductData 
{
    if (_requestingData == true) {
        return;
    }
    _requestingData = true;
    NSArray *product = nil;
    
    NSString *  channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"] ;
    
    //德州扑克之夜Pro版
    if( [channel isEqualToString:@"CN_IOS_APPZY"] )
    {
        product=[[NSArray alloc] initWithObjects:
                 @"com.qufan.texasmjd_6_zs_v1",
                 @"com.qufan.texasmjd_30_zs_v1",
                 @"com.qufan.texasmjd_68_zs_v1",
                 @"com.qufan.texasmjd_128_zs_v1",
                 @"com.qufan.texasmjd_328_zs_v1",
                 @"com.qufan.texasmjd_648_zs_v1",
                 nil];
    }
    //皇家德州扑克（午夜版）
    else if( [channel isEqualToString:@"CN_IOS_APPHJ"] )
    {
        product=[[NSArray alloc] initWithObjects:
                 @"com.qufan.texasmjb_6_zs_v1",
                 @"com.qufan.texasmjb_30_zs_v1",
                 @"com.qufan.texasmjb_68_zs_v1",
                 @"com.qufan.texasmjb_128_zs_v1",
                 @"com.qufan.texasmjb_328_zs_v1",
                 @"com.qufan.texasmjb_648_zs_v1",
                 nil];
    }
    //德州扑克之夜国际版
    else if( [channel isEqualToString:@"CN_IOS_APPGJ"] )
    {
        product=[[NSArray alloc] initWithObjects:
                 @"com.qufan.texasmjc_6_zs_v1",
                 @"com.qufan.texasmjc_30_zs_v1",
                 @"com.qufan.texasmjc_68_zs_v1",
                 @"com.qufan.texasmjc_128_zs_v1",
                 @"com.qufan.texasmjc_328_zs_v1",
                 @"com.qufan.texasmjc_648_zs_v1",
                 nil];
    }
    //土豪德州扑克之夜
    else if( [channel isEqualToString:@"CN_IOS_APPTHZY"] )
    {
        product=[[NSArray alloc] initWithObjects:
                 @"com.qufan.texasmjd_6_zs_v1",
                 @"com.qufan.texasmjd_30_zs_v1",
                 @"com.qufan.texasmjd_68_zs_v1",
                 @"com.qufan.texasmjd_128_zs_v1",
                 @"com.qufan.texasmjd_328_zs_v1",
                 @"com.qufan.texasmjd_648_zs_v1",
                 nil];
    }
    //德州扑克之夜
    else
    {
        product=[[NSArray alloc] initWithObjects:
                 @"item_6_v2_zs",
                 @"item_30_v2_zs",
                 @"item_68_v2__zs",
                 @"item_128_v2__zs",
                 @"item_328_v2_zs",
                 @"item_648_v2_zs", nil];
    }
    
    NSMutableSet * pset = [[NSMutableSet alloc] init];
    for(int i = 0 ; i < product.count ; i++){
        [pset addObject:[[NSString alloc] initWithFormat:@"%@%@",_perfix,product[i]]];
    }

    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: pset];
    request.delegate=self;
    [request start];
    [product release];
}

//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    _requestingData = false;
    //NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品付费数量: %d", [myProduct count]);
    if ([myProduct count] <= 0) {
        //NSLog(@"获取计费点失败！");
        [self RequestProductData];
        [request autorelease];
        return;
    }else{
        _products.clear();
    }
    
    
    for (SKProduct * product  in myProduct) {
        NSLog(@"product %@(%@:%@)" , product.localizedTitle,product.productIdentifier,product.price);
        [product retain];
        _products.push_back(product);
    }
    
    [self pay];
    [request autorelease];
    
}

-(void) pay {
    if (_buyindex >= 0) {
        SKPayment *payment = [SKPayment paymentWithProduct:_products[_buyindex]];
        NSLog(@"---------发送购买请求------------");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}
- (void)requestProUpgradeProductData
{
    NSLog(@"------请求升级数据---------");
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.productid"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}
//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
// ADD-BEGIN by dantezhu in 2015-08-05 09:35:39
    // 经常弹出sku error，无法链接到itunesstore之类的
    return;
// ADD-END

    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alerView show];
    [alerView release];
}

-(void) requestDidFinish:(SKRequest *)request
{
   // NSLog(@"----------反馈信息结束--------------");
    
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    [transactions release];
}

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"购买成功啦"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                
                [alerView show];
                [alerView release];
                break;
            }
            case SKPaymentTransactionStateFailed://交易失败
            
            {[self failedTransaction:transaction];
                 NSLog(@"-----交易失败 --------: %ld, %@", transaction.error.code, transaction.error.localizedFailureReason);
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                                     message:@"购买失败，请重新尝试购买～"
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                
                [alerView2 show];
                [alerView2 release];
            
                break;
            }
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
            }
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
            {
                NSLog(@"-----商品添加进列表 --------");
           
                break;
                 }
            default:
                break;
        }
    }
}

-(void) setCb:(paycb)cb{
    _cb = cb;
}
-(paycb) getCb{
    return _cb;
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction

{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    NSString* jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes
                                       length:transaction.transactionReceipt.length];
    if (_cb){
        _cb(0,std::string([jsonObjectString cStringUsingEncoding:NSUTF8StringEncoding]));
    }
    _buyindex = -1;
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    _cb(1,"error");
    _buyindex = -1;
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@" 交易恢复处理");
    
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
}


#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@",  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"test");
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    [super dealloc];
}
@end

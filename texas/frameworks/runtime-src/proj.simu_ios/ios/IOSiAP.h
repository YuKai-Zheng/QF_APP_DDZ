

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#include <vector>
#include "SDKMacros.h"
@interface IOSiAP : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property std::vector<SKProduct *> products;
@property int buyindex;
@property (nonatomic) paycb cb;
@property bool requestingData;
@property NSString * perfix;
-(void) setcb : (paycb ) cb;
-(paycb) getCb;
-(id) init;
-(void)requestProUpgradeProductData;
-(void)pay;
-(void)RequestProductData ;
-(bool)CanMakePay;
-(int) getBuyIndex : (NSString *) code;
-(void)buy : (NSString * ) code;
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction;
-(void) completeTransaction: (SKPaymentTransaction *)transaction;
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length;
-(void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
-(void)provideContent:(NSString *)product;
-(void)recordTransaction:(NSString *)product;

@end

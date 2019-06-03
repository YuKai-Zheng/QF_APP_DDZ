



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface KeyboardListen : NSObject
{
 
    CGFloat height;
    int show_cb;
    int hide_cb;
    int delete_cb;
    CGFloat x_rate;
    UIButton* deleteButton;
}
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) int show_cb;
@property (nonatomic, assign) int hide_cb;
@property (nonatomic, assign) int delete_cb;
@property (nonatomic, assign) CGFloat x_rate;
@property (nonatomic, assign) UIButton* deleteButton;
+(KeyboardListen*) getInstance;
-(void) keyboardWasShown:(NSNotification *) notif;
- (void) keyboardWasHidden:(NSNotification *) notif;
- (void) deleteContent;
@end


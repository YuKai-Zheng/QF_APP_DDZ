#import "HYKeyboardListener.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "cocos2d.h"
#include "CCDirector.h"
static HYKeyboardListener * _keyboard = nil;
@implementation HYKeyboardListener
@synthesize height,show_cb,hide_cb,delete_cb,x_rate;

+(HYKeyboardListener*) getInstance
{
    @synchronized(self)
    {
        if(_keyboard == nil)
        {
            _keyboard = [[self alloc] init];
        }
    }
    return _keyboard;
}
-(id) init
{
    if(self = [super init])
    {
        height= 0;
        _deleteButton=NULL;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zny_keyboardChangeFrame:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zny_keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(zny_keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void) zny_keyboardChangeFrame:(NSNotification *) notif
{
    if (_deleteButton==NULL)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat fwidth = size.width;
        CGFloat fheight = size.height;
        float  long_width=fwidth;
        float long_height=fheight;
        if (fwidth<fheight) {

            long_width=fheight;
            long_height=fwidth;
        }

        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_deleteButton addTarget:self action:@selector(zny_deleteContent) forControlEvents:UIControlEventTouchUpInside];
        
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        if (!window) return;
        
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
        NSLog(@"long_width:%f",long_width);
        float posx=long_width*x_rate;
        float posy=long_height-height;
        NSLog(@"posx:%f",posx);
        NSLog(@"posy:%f",posy);
        _deleteButton.frame = CGRectMake(posx-25,posy-50,50,50);
        [_rootController.view addSubview:_deleteButton];
    }
    

}
-(void) zny_keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
   
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    NSValue *animationDurationValue =[info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    height= keyboardSize.height;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat fwidth = size.width;
    CGFloat fheight = size.height;
     float rate=height/fheight;
    float  long_width=fwidth;
    float long_height=fheight;
    if (fwidth<fheight) {
        rate=height/fwidth;
        long_width=fheight;
         long_height=fwidth;
    }
    
    float posx=long_width*x_rate;
    float posy=long_height-height;
    if (_deleteButton) {
        [_deleteButton setFrame:CGRectMake(posx-25,posy-50,50,50)];
    }

    if (show_cb>0) {
        cocos2d::LuaBridge::pushLuaFunctionById(show_cb);
        cocos2d::LuaBridge::getStack()->pushFloat(rate);
        cocos2d::LuaBridge::getStack()->executeFunction(1);
    }
}
- (void) zny_keyboardWasHidden:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardSize = [value CGRectValue].size;
    
    height= keyboardSize.height;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat fheight = size.height;
    float rate=height/fheight;

    cocos2d::LuaBridge::pushLuaFunctionById(hide_cb);
    cocos2d::LuaBridge::getStack()->pushFloat(rate);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    
    if (_deleteButton)
    {
        [_deleteButton removeFromSuperview];
        _deleteButton=NULL;
    }
}

-(void) zny_deleteContent
{
    cocos2d::LuaBridge::pushLuaFunctionById(delete_cb);
    cocos2d::LuaBridge::getStack()->pushFloat(0.1);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
}
-(void) dealloc
{
   
    [super dealloc];
}

@end

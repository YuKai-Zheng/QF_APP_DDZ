#import "KeyboardListen.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "cocos2d.h"
#include "CCDirector.h"
static KeyboardListen * _keyboard = nil;
@implementation KeyboardListen
@synthesize height,show_cb,hide_cb,delete_cb,x_rate;


+(KeyboardListen*) getInstance
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
        deleteButton=NULL;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardDidShowNotification object:nil];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
        
        
    }
    return self;
}

-(void) keyboardChangeFrame:(NSNotification *) notif
{
   /* NSLog(@"keyboardChangeFrame.....................................");
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"begin :%f", keyboardSize.height);
    
    value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardSize = [value CGRectValue].size;
    NSLog(@"end :%f", keyboardSize.height);

    
    height= keyboardSize.height;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat fwidth = size.width;
    CGFloat fheight = size.height;
    float rate=height/fheight;
    NSLog(@"ios width:%f",fwidth);
    NSLog(@"ios height:%f",fheight);
    cocos2d::LuaBridge::pushLuaFunctionById(show_cb);
    cocos2d::LuaBridge::getStack()->pushFloat(rate);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    //cocos2d::LuaBridge::releaseLuaFunctionById(show_cb);
    NSLog(@"keyboardChangeFrame over........................................");*/
    
    if (deleteButton==NULL)
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

        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        //[deleteButton setBackgroundImage:[UIImage imageNamed:@"__back_btn"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteContent) forControlEvents:UIControlEventTouchUpInside];
        
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
        deleteButton.frame = CGRectMake(posx-25,posy-50,50,50);
        [_rootController.view addSubview:deleteButton];
    }
    

}
-(void) keyboardWasShown:(NSNotification *) notif
{
    NSLog(@"keyboardWasShown.......................................");
    NSDictionary *info = [notif userInfo];
   
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"begin :%f", keyboardSize.height);
    
     value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
     keyboardSize = [value CGRectValue].size;
     NSLog(@"end :%f", keyboardSize.height);
    
     value = [info objectForKey:UIKeyboardCenterBeginUserInfoKey];
     keyboardSize = [value CGRectValue].size;
    NSLog(@"begin1 :%f", keyboardSize.height);
    
     value = [info objectForKey:UIKeyboardCenterEndUserInfoKey];
     keyboardSize = [value CGRectValue].size;
    NSLog(@"begin2 :%f", keyboardSize.height);

    
     value = [info objectForKey:UIKeyboardBoundsUserInfoKey];
     keyboardSize= [value CGRectValue].size;
     NSLog(@"begin3 :%f", keyboardSize.height);

    NSValue *animationDurationValue =[info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    float time=animationDuration;
    NSLog(@"animationDuration:%f",time);

    
    
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
    
    NSLog(@"ios width:%f",fwidth);
    NSLog(@"ios height:%f",fheight);
    float posx=long_width*x_rate;
    float posy=long_height-height;
    if (deleteButton) {
    [deleteButton  setFrame:CGRectMake(posx-25,posy-50,50,50)];
    }
    NSLog(@"show_cb:%d",show_cb);
    if (show_cb>0) {
    cocos2d::LuaBridge::pushLuaFunctionById(show_cb);
    cocos2d::LuaBridge::getStack()->pushFloat(rate);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    //cocos2d::LuaBridge::releaseLuaFunctionById(show_cb);
    }
    NSLog(@"keyboardWasshow..................................... over");
    
    }
- (void) keyboardWasHidden:(NSNotification *) notif
{
     NSLog(@"keyboardWasHidden");
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"begin :%f", keyboardSize.height);
    
    value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardSize = [value CGRectValue].size;
    NSLog(@"end :%f", keyboardSize.height);
    
    height= keyboardSize.height;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat fwidth = size.width;
    CGFloat fheight = size.height;
    float rate=height/fheight;
    NSLog(@"ios width:%f",fwidth);
    NSLog(@"ios height:%f",fheight);
    cocos2d::LuaBridge::pushLuaFunctionById(hide_cb);
    cocos2d::LuaBridge::getStack()->pushFloat(rate);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    //cocos2d::LuaBridge::releaseLuaFunctionById(hide_cb);
    NSLog(@"keyboardWasHidden over");
    
    if (deleteButton)
    {
        [deleteButton  removeFromSuperview];
        deleteButton=NULL;
    }
}

- (void) deleteContent
{
    
    NSLog(@"deleteContent ");
    cocos2d::LuaBridge::pushLuaFunctionById(delete_cb);
    cocos2d::LuaBridge::getStack()->pushFloat(0.1);
    cocos2d::LuaBridge::getStack()->executeFunction(1);

    
}
-(void) dealloc
{
   
    [super dealloc];
}

@end
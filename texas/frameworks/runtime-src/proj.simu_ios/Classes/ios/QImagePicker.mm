

#import <QuartzCore/QuartzCore.h>

#import "QImagePicker.h"

#include "platform/CCImage.h"
#include "CCDirector.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

#include "ImagePostHelper.h"

USING_NS_CC;

#define IMAGEPACKER_DEFAULT_SIZE 300.0


@implementation QImagePicker
@synthesize imagePicker = _imagePicker;

static QImagePicker* s_instance = nil;


+(QImagePicker*)getInstance
{
    if (s_instance==nil)
    {
        s_instance = [[QImagePicker alloc] init];
    }
    return s_instance;
}


- (id)init
{
    self = [super init];
    if (self) {
        _photoPath = nil;
        _key = nil;
        _url = nil;
        _rootController = nil;
        _luacb = -1 ;
        _upload = 0 ;
        if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
        {
            // warning: addSubView doesn't work on iOS6
            NSArray* array=[[UIApplication sharedApplication]windows];
            UIWindow* win=[array objectAtIndex:0];
            
            UIView* ui=[[win subviews] objectAtIndex:0];
            _rootController = (UIViewController*)[ui nextResponder];
        }
        else
        {
            // use this method on ios6
            _rootController =[[[UIApplication sharedApplication] keyWindow ] rootViewController];
        }
        
        //判断设备
        NSString *  nsStrIpad=@"iPad";
        bool  bIsiPad=false;
        bIsiPad=[self checkDevice:nsStrIpad];
        bool isSim = [self checkDevice:@"iPhone Simulator"];
        _isPhone = true||isSim;
        if (bIsiPad) {
            _isPhone = false;
        }
        
        _imageSize = CGSizeMake(300, 300);
        
        _imageSaveKind = Customsize;
    }
    return self;
}

- (void)dealloc
{
    [_imagePicker release];
    [_photoPath release];
    [_rootController release];
    [_key release];
    [super dealloc];
}


- (void) openFromAlbum
{
    if (_isPhone) {
        //调用前必须设置竖屏，不然游戏崩溃
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            [self setPortraitOrientation];
        }
        
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
            //
        }
        pickerImage.delegate = self;
        pickerImage.allowsEditing = YES;
        if (_edit==0)
        {
            pickerImage.allowsEditing = NO;
        }
//        [_rootController presentModalViewController:pickerImage animated:NO];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_rootController presentViewController:pickerImage animated:YES completion:nil];
        }];
        
        [pickerImage release];
    }
}

- (void) openFromCamare
{
    //调用前必须设置竖屏，不然游戏崩溃
    if (_isPhone && [[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [self setPortraitOrientation];
    }
    
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    picker.allowsEditing = YES;//设置可编辑
   if (_edit==0)
    {
       picker.allowsEditing = NO;
    }
    picker.sourceType = sourceType;

//    [_rootController presentModalViewController:picker animated:YES];//进入照相界面
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [_rootController presentViewController:picker animated:YES completion:nil];
      }];
    [picker release];
}

-(void) setPhotoPath:(NSString * )path
{
    [_photoPath release];
    _photoPath = [[NSString alloc]initWithString:path]; //copy
}

- (void)setUpload:(int)upload{
    _upload = upload;
}

//保存图片 ,返回路径
- (void) saveImage:(UIImage *)image {
    if (image == nil) {
        [image release];
        return ;
    }

    UIImage* img = image;
     if (_edit>0) 
     {
        img = [self reSizeImage:image toSize:_imageSize];
    }
     else
     {
         float  width=img.size.width;
         float  height=image.size.height;
         float  rate=width/height;
         _imageSize = CGSizeMake(1080*rate, 1080);
         img = [self reSizeImage:image toSize:_imageSize];
     }

    [image release];
    NSData* img_data = nil;
    if (img) {
        if (_edit>0)
        {
        img_data = UIImageJPEGRepresentation(img, 0.5);
        }else
        {
           img_data = UIImageJPEGRepresentation(img, 0.3);
        }
        BOOL ret = NO;
        if (img_data) {
            [[NSFileManager defaultManager] removeItemAtPath:_photoPath error:nil];
            ret =  [img_data writeToFile:_photoPath atomically:YES];
            if (_upload > 0 ) {
                NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"image",@"name",@"head.png",@"filename",_photoPath,@"path", nil];
                NSArray * arr = [[NSArray alloc] initWithObjects:dic, nil];
                [ImagePostHelper postRequestWithURL:_url postParems:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uin],@"uin",_key,@"key", nil] picInfo:arr luacb:_luacb];
            }
        }
        if (!ret) {
        }
    }
    // cb to lua
    NSString* status = @"0";
    if ( _luacb > 0 ) {
        LuaBridge::pushLuaFunctionById(_luacb);
        LuaBridge::getStack()->pushString([status UTF8String]);
        LuaBridge::getStack()->executeFunction(1);
    }
}


-(void) setLandscapeOrientation
 {
    if(_orientation ==UIInterfaceOrientationLandscapeLeft) {
        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeLeft];
    }
    else{
        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeRight];
    }
 }
 
 -(void) setPortraitOrientation
 {
    _orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(_orientation != UIInterfaceOrientationLandscapeLeft && _orientation != UIInterfaceOrientationLandscapeRight) {
        _orientation = UIInterfaceOrientationLandscapeRight;
    }
     [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationPortraitUpsideDown];
 }

-(void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

//按比例缩放
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


//自定义大小
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void)setImageSize:(CGSize)size
{
    _imageSize = size;
}


-(void)setImageSaveKind:(ImageSaveKind)kind
{
    _imageSaveKind = kind;
}

#pragma mark –
#pragma mark Camera View Delegate Methods

//点击相册中的图片或者照相机照完后点击use 后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (_isPhone && [[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [self setLandscapeOrientation];
    }
    //打印出字典中的内容
//    NSLog(@"get the media info: %@", info);
    //获取媒体类型
//    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    NSLog(@"get the media mediaType: %@", mediaType);
    UIImage *image;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){//如果打开相册
        if (_isPhone) {
            [picker dismissModalViewControllerAnimated:YES];//关掉相册dismissPopoverAnimated
        }else{
            [self.imagePicker dismissPopoverAnimated:YES];
        }
        if (_edit>0) {image = [[info objectForKey:UIImagePickerControllerEditedImage] retain];}
        else {image = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];}
    }
    else{//照相机
        [picker dismissModalViewControllerAnimated:YES];//关掉照相机
         if (_edit>0) {image = [[info objectForKey:UIImagePickerControllerEditedImage] retain];}
        else {image = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];}
    }
    
    [self hideStatusBar];
    
    //把选中的图片添加到界面中
    [self performSelector:@selector(saveImage:)
               withObject:image
               afterDelay:0.5];
}

//点击cancel调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //设置回横屏，不然游戏会崩溃
    if (_isPhone && [[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [self setLandscapeOrientation];
    }
    [self hideStatusBar];
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(bool)checkDevice:(NSString*)name
{
	NSString* deviceType = [UIDevice currentDevice].model;
	NSRange range = [deviceType rangeOfString:name];
	return range.location != NSNotFound;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (!_isPhone)
    {
        [self hideStatusBar];
        cocos2d::Size winSize =  Director::getInstance()->getWinSize();
        
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            viewController.contentSizeForViewInPopover = CGSizeMake(winSize.width/2, winSize.width/2+140);
        }else{
            viewController.preferredContentSize = CGSizeMake(winSize.width/2, winSize.width/2 + 142);
        }
    }
}
-(void) setLuaCB:(int)cb {
    _luacb = cb;
}

- (void)setUin:(int)uin {
    _uin = uin;
}
- (void)setKey:(NSString *)key {
    [_key release];
    _key = [[NSString alloc] initWithString:key];
}
- (void)setUrl:(NSString *)url {
    [_url release];
    _url = [[NSString alloc] initWithString:url];
}
- (void)setEdit:(int)edit {
    _edit = edit;
}

@end
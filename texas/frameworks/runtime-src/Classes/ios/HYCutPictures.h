
// jiangliwu 2014-11-20
// thx jopix..


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


enum ImageSaveKind {
    UniformScale = 1,
    Customsize,
    };

@interface HYCutPictures : NSObject<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>{
    NSString* _photoPath;
    UIViewController * _rootController;
    BOOL _isPhone;
    CGSize _imageSize;
    enum ImageSaveKind _imageSaveKind;
    int _luacb ;
    int _uin;
    NSString * _key;
    NSString * _url;
    int _upload ;
    UIInterfaceOrientation _orientation;
    int _edit;
}

+(HYCutPictures*) getInstance;

@property (retain,nonatomic)UIPopoverController *imagePicker;

-(id)init;

-(void)zny_setPortraitOrientation;
-(void)zny_setPhotoPath:(NSString *) path;
-(void)zny_openFromCamare;
-(void)zny_openFromAlbum;
-(void)zny_setImageSize:(CGSize)size;
-(void)zny_setImageSaveKind:(enum ImageSaveKind) kind;
-(void)zny_setLuaCB : (int) cb;
-(void)zny_setUin : (int) uin;
-(void)zny_setKey : (NSString * ) key;
-(void)zny_setUrl : (NSString * ) url;
-(void)zny_setUpload : (int) upload;
-(void)zny_setEdit : (int) edit;
@end

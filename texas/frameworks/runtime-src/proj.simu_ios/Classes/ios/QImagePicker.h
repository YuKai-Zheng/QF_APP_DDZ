
// jiangliwu 2014-11-20
// thx jopix..


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


enum ImageSaveKind {
    UniformScale = 1,
    Customsize,
    };

@interface QImagePicker : NSObject<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>{
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

+(QImagePicker*) getInstance;

@property (retain,nonatomic)UIPopoverController *imagePicker;

-(id)init;

-(void)setPhotoPath:(NSString *) path;
-(void)openFromCamare;
-(void)openFromAlbum;
-(void)setImageSize:(CGSize)size;
-(void)setImageSaveKind:(enum ImageSaveKind) kind;
-(void)setLuaCB : (int) cb;
-(void)setUin : (int) uin;
-(void)setKey : (NSString * ) key;
-(void)setUrl : (NSString * ) url;
-(void)setUpload : (int) upload;
-(void)setEdit : (int) edit;
@end

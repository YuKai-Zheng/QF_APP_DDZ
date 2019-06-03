package com.qufan.ddz.uploadphoto;

import android.graphics.Bitmap;
import android.net.Uri;

public interface UploadUserPhotoListener {
	//本地照片的回调方法
	public void initCrop(Uri uri);
	//拍照之后的回调方法
	public void initCrop();
	//设置用户裁剪好的图片，准备上传
	public void setBitmap(Bitmap bitmap);
}

package com.qufan.ddz.uploadphoto;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.net.Uri;
import android.os.AsyncTask;
import android.provider.MediaStore;

import com.github.kevinsawicki.http.HttpRequest;
import com.qufan.texas.util.Tools;
import com.qufan.texas.util.Util;


import android.util.Log;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import android.graphics.BitmapFactory;
import android.content.ContentResolver;  
import android.content.ContentValues; 
import android.provider.MediaStore;
import android.provider.MediaStore.Images; 
import android.provider.MediaStore.Images.Media;  
import android.database.Cursor; 
import java.lang.ref.WeakReference;
import com.qufan.util.XLog;  
public class UploadPhotoUtil implements UploadUserPhotoListener {
	public static String HTTP_HOST = "ddz.qfighting.com";
	public static String UPLOAD_ICON_URL = "http://" + HTTP_HOST
			+ "/portrait/upload";
	private Bitmap bitmap = null;
	private static UploadPhotoUtil instance;
	private int uin;
	private String key;
	private String cachePath;
	private int luaCB;

	private String path;
    private boolean isEdit;
	public static synchronized UploadPhotoUtil getInstance() {
		if (instance == null) {
			instance = new UploadPhotoUtil();
			AppActivity.setUploadUserPhotoListener(instance);
		}
		return instance;
	}

	private static synchronized UploadPhotoUtil sycUploadPhotoUtil() {
		if (instance == null) {
			instance = new UploadPhotoUtil();
			AppActivity.setUploadUserPhotoListener(instance);
		}
		return instance;
	}

	/**
	 * 上传图片
	 */
	public void uploadPhoto() {
		if (bitmap != null) {
			cacheBitmap(bitmap);
			new ImagePost().execute(bitmap);
		} else {
			
		}
	}

	private Uri mDataUri = null;

	/**
	 * 获取拍照
	 * 
	 * @param cachePath
	 * @param key
	 * @param url
	 * @param uin
	 * @param cb
	 */
	public void getCamera(String cachePath, String key, String url, int uin,
			int cb,boolean edit) {
		this.uin = uin;
		this.key = key;
		this.cachePath = cachePath;
		this.isEdit=true;
		if (edit==false) {
			this.isEdit=false;
		}
		UPLOAD_ICON_URL = url;
		this.luaCB = cb;
		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);// MediaStore.
		File file = new File(Util.getExternalPath() + File.separator
				+ "tmp.jpeg");
		System.out.println(file.getAbsolutePath());
		mDataUri = Uri.fromFile(file);
		intent.putExtra(MediaStore.EXTRA_OUTPUT, mDataUri);
		try {
			((Activity) Util.context).startActivityForResult(intent, 2004);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 获取本地图片
	 * 
	 * @param cachePath
	 * @param key
	 * @param url
	 * @param uin
	 * @param cb
	 */
	public void getLocal(String cachePath, String key, String url, int uin,
			int cb,boolean edit) {
		this.uin = uin;
		this.key = key;
		this.cachePath = cachePath;
		this.isEdit=true;
		if (edit==false) {
			this.isEdit=false;
		}
		UPLOAD_ICON_URL = url;
		this.luaCB = cb;
		try {
			Intent intent = new Intent(Intent.ACTION_PICK,
					MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
			((Activity) Util.context).startActivityForResult(intent, 2005);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private class ImagePost extends AsyncTask<Bitmap, Void, Object[]> {
		@Override
		protected Object[] doInBackground(Bitmap... params) {
			Bitmap bitmap = params[0];
			HttpRequest request = HttpRequest.post(UPLOAD_ICON_URL);
			request.part("uin", uin);
			request.part("key", key);

			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			bitmap.compress(CompressFormat.JPEG, 100, bos);
			ByteArrayInputStream in = new ByteArrayInputStream(
					bos.toByteArray());
			request.part("image", "image.jpg", "image/*", in);
			String body = null;
			boolean ok =false;
			try {
			 ok = request.ok();
		
			} catch (Exception e) {
				Log.e("Exception e","mmmmm");
			    e.printStackTrace();
			    XLog.e("ImagePost:"+e.toString());
			   XLog.e("ImagePost:"+e.getMessage());
               return new Object[] { ok, body, bitmap };
		      }
			if (ok) {
			  body = request.body();
			  return new Object[] { ok, body, bitmap };
		    }
		    return new Object[] { ok, body, bitmap };
		}

		@Override
		protected void onPostExecute(Object[] result) {
			if (((Boolean) result[0]) == true) {
				JSONObject json = Tools.getJSONObject((String) result[1]);
				if (Tools.getJsonInt(json, "ret") == 0) {
					Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
						{
	                       @Override
	                       public void run() {
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaCB, "1"); // 1 成功
	                      }
	                  }); 

				} else {
					// 失败
					Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
						{
	                       @Override
	                       public void run() {
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaCB, "-1"); // -1 失败
	                      }
	                  }); 
				}
			}
		}
	}

	@Override
	public void initCrop() {
		if (mDataUri==null) {
			XLog.e("mDataUri==null");
		}else {
		initCrop(mDataUri);
	   }
	}

	@Override
	// TODO: 该方法采用了未公开的 Intent.Action 存在兼容性问题
	public void initCrop(Uri data) {
		// path = data.toString();
		// Log.i("path","@@"+path);
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(data, "image/*");
		intent.putExtra("noFaceDetection", true);
		intent.putExtra("crop", "true");// 设置裁剪
		intent.putExtra("aspectX", 1);// aspectX aspectY 是宽高的比例
		intent.putExtra("aspectY", 1);
		intent.putExtra("outputX", 200);// outputX outputY 是裁剪图片宽高
		intent.putExtra("outputY", 200);
		intent.putExtra("return-data", true);
		if (this.isEdit==true) 
		{
			try {
				((Activity) Util.context).startActivityForResult(intent, 2006);
			} catch (Exception e) {
				e.printStackTrace();
			}
	    }
	    else
	    {
           Bitmap bitmap =  convertToBitmap(UploadPhotoUtil.getFilePathFromURI(data),1080,1080);
           setBitmap(bitmap);
       }
       
	}

	@Override
	public void setBitmap(Bitmap bitmap) {
		// JavaInteractionC.imagePath = path.substring(8);
		this.bitmap = bitmap;
		uploadPhoto();
	}

	/**
	 * 在缓存路径创建图片
	 */
	private void cacheBitmap(Bitmap photo) {
		if (null != photo) {

			File file = new File(cachePath);
			if (file.exists() && file.isFile()) {
				file.delete();
			}

			try {
				BufferedOutputStream out = new BufferedOutputStream(
						new FileOutputStream(file));
				photo.compress(Bitmap.CompressFormat.JPEG, 80, out);
				out.flush();
				out.close();

				System.out.println(" -- success write img -- " + cachePath);

				Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
					{
                       @Override
                       public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaCB, "0"); // 0 正在上传
                      }
                  }); 

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

 private void cacheBitmapNoEdit() {
		
			File file = new File(cachePath);
			if (file.exists() && file.isFile()) {
				file.delete();
			}

			try {

				System.out.println(" -- success write img -- " + cachePath);
				Cocos2dxLuaJavaBridge
						.callLuaFunctionWithString(luaCB, cachePath);


			} catch (Exception e) {
				e.printStackTrace();
			}
		
	}

    public static String getFilePathFromURI(Uri uri) 
    {

        // 不管是拍照还是选择图片每张图片都有在数据中存储也存储有对应旋转角度orientation值
        // 所以我们在取出图片是把角度值取出以便能正确的显示图片,没有旋转时的效果观看

        ContentResolver cr =((Activity) Util.context).getContentResolver();
        Cursor cursor = cr.query(uri, null, null, null, null);// 根据Uri从数据库中找
        if (cursor == null) {
            return uri.getPath();
        }

        cursor.moveToFirst();// 把游标移动到首位，因为这里的Uri是包含ID的所以是唯一的不需要循环找指向第一个就是了
        String filePath = cursor.getString(cursor.getColumnIndex("_data"));// 获取图片路

        return filePath;
    }
    public Bitmap convertToBitmap(String path, int w, int h) {
            BitmapFactory.Options opts = new BitmapFactory.Options();
            // 设置为ture只获取图片大小
            opts.inJustDecodeBounds = true;
            opts.inPreferredConfig = Bitmap.Config.ARGB_8888;
            // 返回为空
            BitmapFactory.decodeFile(path, opts);
            int width = opts.outWidth;
            int height = opts.outHeight;
            float scaleWidth = 0.f, scaleHeight = 0.f;
            if (width > w || height > h) {
                // 缩放
                scaleWidth = ((float) width) / w;
                scaleHeight = ((float) height) / h;
            }
            opts.inJustDecodeBounds = false;
            float scale = Math.max(scaleWidth, scaleHeight);
            opts.inSampleSize = (int)scale;
            WeakReference<Bitmap> weak = new WeakReference<Bitmap>(BitmapFactory.decodeFile(path, opts));
            return Bitmap.createScaledBitmap(weak.get(), w, h, true);
        }

    private class ImageNoEditPost extends AsyncTask<String, Void, Object[]> {
		@Override
		protected Object[] doInBackground(String... params) {
			String filePath = params[0];
           
           try {

                Bitmap bitmap=BitmapFactory.decodeFile(filePath);
                if (bitmap!=null) {
                	System.out.println(" bitmap==zai ");
                }
			    System.out.println(" BufferedOutputStream out ");
			   
			     ByteArrayOutputStream bos = new ByteArrayOutputStream();
			     bitmap.compress(CompressFormat.JPEG, 20, bos);
			     ByteArrayInputStream in = new ByteArrayInputStream(
					bos.toByteArray());
			
			  HttpRequest request = HttpRequest.post(UPLOAD_ICON_URL);
			  request.part("uin", uin);
			  request.part("key", key);
			
			 // FileInputStream in = new FileInputStream(filePath);
			  request.part("image", "image.jpg", "image/*", in);
			  String body = null;
			  boolean ok = request.ok();
			  if (ok) {
				  body = request.body();
			   }

			    return new Object[] { ok, body, filePath };
			
			  } catch (Exception e) 
			  {
				  e.printStackTrace();
				return new Object[] {};
			  }
			
		}

		@Override
		protected void onPostExecute(Object[] result) {
			if (((Boolean) result[0]) == true) {
				JSONObject json = Tools.getJSONObject((String) result[1]);
				if (Tools.getJsonInt(json, "ret") == 0) {
					
				} else {
					
				}
			}
		}
	}
}

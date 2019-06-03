/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.util.ArrayList;
import java.util.HashMap;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Service;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.media.AudioManager;
import android.media.JetPlayer.OnJetEventListener;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.http.SslError;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.provider.Settings;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.JsResult;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.Toast;
//import cn.jpush.android.api.JPushInterface;

import com.qufan.ddz.uploadphoto.UploadUserPhotoListener;
import com.qufan.pay.sdk.TexasConstant;
import com.qufan.special.sdk.SpecialConstant;
import com.qufan.special.sdk.SpecialFactory;
//import com.qufan.pay.sdk.zimon.StartRecord;
import com.qufan.texas.interf.QFPayResultListener;
import com.qufan.pay.UnitySDKFactory;
import com.qufan.texas.util.RelayoutTool;
import com.qufan.texas.util.Tools;
import com.qufan.texas.util.Util;
import com.qufan.util.RHelper;
import com.umeng.analytics.MobclickAgent;
import com.tencent.connect.UserInfo;
import com.tencent.connect.common.Constants;
import com.tencent.tauth.Tencent;
import com.qufan.login.QQ.QQLogin;

import com.qufan.util.XLog;

import android.content.res.Configuration;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import android.webkit.ValueCallback;
//import android.webkit.WebChromeClient.FileChooserParams;

// The name of .so is specified in AndroidMenifest.xml. NativityActivity will load it automatically for you.
// You can use "System.loadLibrary()" to load other .so files.


@SuppressLint("SetJavaScriptEnabled")
public class AppActivity extends Cocos2dxActivity{
//	public static StartRecord mStartRecord;
	public static  AppActivity instance;
	static String hostIPAdress="0.0.0.0";
	private PowerManager mPowerManager = null;
	private final int UPDATE_HANDLER = 7377;
	public static UploadUserPhotoListener uploadUserPhotoListener;
	public static QFPayResultListener payResultListener;
	public static int luaWebViewHandler = -1;
    
    public ValueCallback<Uri> mUploadMessage;
    public ValueCallback<Uri[]> mUploadMessageForAndroid5;
    
    public final static int FILECHOOSER_RESULTCODE = 1;
    public final static int FILECHOOSER_RESULTCODE_FOR_ANDROID_5 = 2;


	public static void setUploadUserPhotoListener(UploadUserPhotoListener listener){
		AppActivity.uploadUserPhotoListener = listener;
	}
	public static void setPayResultListener(QFPayResultListener listener) {
		AppActivity.payResultListener = listener;
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		instance=this;

		super.onCreate(savedInstanceState);

		SpecialFactory.getInstance().initWithActivity(this);
		UnitySDKFactory.getInstance();
		Util.context = this;
		this.mPowerManager = (PowerManager) this.getSystemService(Context.POWER_SERVICE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
		hostIPAdress = getHostIpAddress();
		new HeartTread().start();
	}
	

	private boolean isNetworkConnected() {
	        ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
	        if (cm != null) {  
	            NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
			ArrayList networkTypes = new ArrayList();
			networkTypes.add(ConnectivityManager.TYPE_WIFI);
			try {
				networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
			} catch (NoSuchFieldException nsfe) {
			}
			catch (IllegalAccessException iae) {
				throw new RuntimeException(iae);
			}
			if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
	                return true;  
	            }  
	        }  
	        return false;  
	    } 
	 
	public String getHostIpAddress() {
		WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
		WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
		int ip = wifiInfo.getIpAddress();
		return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
	}
	
	public static String getLocalIpAddress() {
		return hostIPAdress;
	}
	
	
	public static String getSDCardPath() {
		if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
			String strSDCardPathString = Environment.getExternalStorageDirectory().getPath();
           return  strSDCardPathString;
		}
		return null;
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if(SpecialFactory.getInstance().isSpecial()){
			SpecialFactory.getInstance().onActivityResult(requestCode, resultCode, data);
		}

		if (resultCode == Activity.RESULT_OK) {
			switch (requestCode) {
			case 2004:
			    if (uploadUserPhotoListener==null) {
			    	 XLog.e("uploadUserPhotoListener==null");
			    }
			    else {
				uploadUserPhotoListener.initCrop();
			    }
				break;
			case 2005:
				if (null != data && data.getData() != null) {
					uploadUserPhotoListener.initCrop(data.getData());
				}
				break;
			case 2006:
				if (null != data) {
					Bitmap bitmap = data.getParcelableExtra("data");
					if (bitmap != null && !bitmap.isRecycled()) {
						uploadUserPhotoListener.setBitmap(bitmap);
					}
				}
				break;
			}
		}
		if (11101 == requestCode) {
			Tencent.onActivityResultData(requestCode, resultCode, data, QQLogin.getInstance().getQQLoginListener());//土豪单机德州打包时要注释掉本行
		}
        
        if (requestCode == FILECHOOSER_RESULTCODE) {
            if (null == mUploadMessage)
                return;
            Uri result = data == null || resultCode != RESULT_OK ? null: data.getData();
            mUploadMessage.onReceiveValue(result);
            mUploadMessage = null;
            
        } else if (requestCode == FILECHOOSER_RESULTCODE_FOR_ANDROID_5){
            if (null == mUploadMessageForAndroid5)
                return;
            Uri result = (data == null || resultCode != RESULT_OK) ? null: data.getData();
            if (result != null) {
                mUploadMessageForAndroid5.onReceiveValue(new Uri[]{result});
            } else {
                mUploadMessageForAndroid5.onReceiveValue(new Uri[]{});
            }
            mUploadMessageForAndroid5 = null;
        }
	}
	private class HeartTread extends Thread{
		@Override
		public void run() {
			super.run();
			while (true) {
				try {
					watch();
					Thread.sleep(1000);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}
	private int background = 0;
	public void watch() {
		if ((!mPowerManager.isScreenOn() || !Tools.isAppOnForeground(getContext()))) {
			background++;
			if (background > 60*4) {// 锁屏了120秒 将退出整个游戏
				AppActivity.this.finish();
				Tools.exitsure(AppActivity.this);
			}
		} else {
			background = 0;
		}
	}
	
	/**
	 * 宝箱弹框
	 */
	private static FrameLayout chestPop=null;
	
	public static void showWebActivity(Context context, String url,float x,float y,float w,float h,int cb,int cb2) {
		 if (chestPop != null) {
		 	return;
		 }

		luaWebViewHandler = cb2;
		final View popView = View.inflate((Activity)context, RHelper.getValue(RHelper.layout, "d_activity"), null);
		RelayoutTool.relayoutViewHierarchy(popView);
	
		ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.WRAP_CONTENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);

        //lp.gravity = Gravity.RIGHT;  
        //lp.gravity = Gravity.CENTER;//|Gravity.TOP;  
		chestPop = new FrameLayout(AppActivity.instance);
		chestPop.setLayoutParams(lp);
		chestPop.setFocusable(true);
		chestPop.setFocusableInTouchMode(true);
		chestPop.setBackgroundDrawable(new BitmapDrawable()); 

		final Button mWebBack = (Button) popView.findViewById(RHelper.getValue(RHelper.id,"events_back_btn"));
		mWebBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
			  //AppActivity.instance.runOnGLThread
			 Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
						{
                           @Override
                           public void run() {
                           	 Log.d("AppActivity", "runOnGLThread ");
                           	 
                            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaWebViewHandler, "remove");
                             luaWebViewHandler = -1;
                            Cocos2dxLuaJavaBridge.releaseLuaFunction(luaWebViewHandler);
                           
                             Log.d("AppActivity", "runOnGLThread over");
                          }
                      }); 
			  
			 
				
			}
		});
		WebView mWebView = (WebView) popView.findViewById(RHelper.getValue(
				RHelper.id, "events_show_wv"));
		WebSettings webSettings = mWebView.getSettings();
		webSettings.setJavaScriptEnabled(true);// 这两句必须设置，否则webview里面的点击都会没有效果
		webSettings.setLoadsImagesAutomatically(true);//
		mWebView.requestFocus();

		// mWebView.requestFocusFromTouch();
		mWebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);// 设置为无缓存
		mWebView.setBackgroundColor(0);// 设置背景颜色

		mWebView.getSettings().setLoadWithOverviewMode(true);
		mWebView.getSettings().setUseWideViewPort(true);
		
		mWebView.setWebChromeClient(new WebChromeClient(){
			@Override
			public boolean onJsAlert(WebView view, String url, String message,
					JsResult result) {
				// TODO Auto-generated method stub
				Toast.makeText(Util.context, message, Toast.LENGTH_LONG).show();
				result.confirm();
				return super.onJsAlert(view, url, message, result);
			}
            
            
            //扩展浏览器上传文件
            //3.0++版本
            public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType) {
                AppActivity.instance.openFileChooserImpl(uploadMsg);
            }
            
            //3.0--版本
            public void openFileChooser(ValueCallback<Uri> uploadMsg) {
                AppActivity.instance.openFileChooserImpl(uploadMsg);
            }
            
            public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType, String capture) {
                AppActivity.instance.openFileChooserImpl(uploadMsg);
            }
		});
		
		mWebView.setWebViewClient(new WebViewClient() {
			public void onReceivedSslError(WebView view,
					SslErrorHandler handler, SslError error) {
				handler.proceed(); // 接受所有网站的证书
			}

			@Override
			public void onPageStarted(WebView view, String url, Bitmap favicon) {// 这个方法是在webview开始loading的时候会自动调用
				super.onPageStarted(view, url, favicon);
				popView.findViewById(
						RHelper.getValue(RHelper.id, "events_download_pro"))
						.setVisibility(View.VISIBLE);
			}

			@Override
			public void onPageFinished(WebView view, String url) {// 这个方法是webview在loading结束的时候会自动调用可以在这里调用进度条关闭
				super.onPageFinished(view, url);
				popView.findViewById(
						RHelper.getValue(RHelper.id, "events_download_pro"))
						.setVisibility(View.INVISIBLE);
			}
			
		});
		mWebView.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                case MotionEvent.ACTION_UP:
                    if (!v.hasFocus()) {
                        v.requestFocus();
                    }
                    break;
                }
                return false;
            }
        });


		chestPop.setOnKeyListener(new OnKeyListener()
		{
		    public boolean onKey(View v, int keyCode, KeyEvent event)
		    {   System.out.println("onKey");
		        if (event.getAction() == KeyEvent.ACTION_DOWN && keyCode == KeyEvent.KEYCODE_BACK)
		           {    System.out.println("KEYCODE_BACK");
                       if(chestPop!=null)
				       {
					     mFrameLayout.removeView(chestPop);
					     chestPop = null;
					     removeWebViewLua();
					     return true;
			           }
		           }
		        return false;
		    }
		});
 
		mWebView.loadUrl(url);
		chestPop.addView(popView);
        mFrameLayout.addView(chestPop);
	}
    
    private void openFileChooserImpl(ValueCallback<Uri> uploadMsg) {
        mUploadMessage = uploadMsg;
        Intent i = new Intent(Intent.ACTION_GET_CONTENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        i.setType("image/*");
        startActivityForResult(Intent.createChooser(i, "File Chooser"), FILECHOOSER_RESULTCODE);
    }
    
    private void openFileChooserImplForAndroid5(ValueCallback<Uri[]> uploadMsg) {
        mUploadMessageForAndroid5 = uploadMsg;
        Intent contentSelectionIntent = new Intent(Intent.ACTION_GET_CONTENT);
        contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE);
        contentSelectionIntent.setType("image/*");
        
        Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
        chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent);
        chooserIntent.putExtra(Intent.EXTRA_TITLE, "Image Chooser");
        
        startActivityForResult(chooserIntent, FILECHOOSER_RESULTCODE_FOR_ANDROID_5);
    }

	public static void  removeWebViewLua(){
		if (luaWebViewHandler != -1) 
		{      Log.d("AppActivity", "luaWebViewHandler != -1");
				 Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
				{
		           @Override
		           public void run() 
		           {
		           	 Log.d("AppActivity", "runOnGLThread ");
		            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaWebViewHandler, "remove");
		             
		              luaWebViewHandler = -1;
		              Log.d("AppActivity", "luaWebViewHandler = -1");
		            Cocos2dxLuaJavaBridge.releaseLuaFunction(luaWebViewHandler);
		             Log.d("AppActivity", "runOnGLThread over");
		          }
		      }); 
		}

	}
	public static void closeWebActivity(){
		Log.d("AppActivity", "closeWebActivity");
		if(chestPop!=null){
			Log.d("AppActivity", "removeView");
			mFrameLayout.removeView(chestPop);
			chestPop = null;
			Log.d("AppActivity", "chestPop = null");
            removeWebViewLua();
		}
	}

    @Override
    protected void onDestroy() {
        Log.d("AppActivity", "onDestroy");
		if(chestPop!=null){
			Log.d("AppActivity", "removeView");
			mFrameLayout.removeView(chestPop);
			chestPop = null;
			Log.d("AppActivity", "chestPop = null");
            removeWebViewLua();
		}
        super.onDestroy();
		SpecialFactory.getInstance().onDestroy();
    }
	
	@Override
	protected void onResume() {
		MobclickAgent.onResume(this);
		super.onResume();
		SpecialFactory.getInstance().onResume();
	}

   @Override
    protected void onRestart() {
        super.onRestart();
		SpecialFactory.getInstance().onRestart();
    }
	@Override
	protected void onPause() {
		MobclickAgent.onPause(this);
		super.onPause();
		SpecialFactory.getInstance().onPause();
	}
 	@Override
   protected void onStop() {
		super.onStop();
		SpecialFactory.getInstance().onStop();
   }
	//媒体音量设置
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		AudioManager audio = (AudioManager) getSystemService(Service.AUDIO_SERVICE);
	    switch (keyCode) {
		    case KeyEvent.KEYCODE_VOLUME_UP:
		        audio.adjustStreamVolume(
		            AudioManager.STREAM_MUSIC,
		            AudioManager.ADJUST_RAISE,
		            AudioManager.FLAG_PLAY_SOUND | AudioManager.FLAG_SHOW_UI);
		        return true;
		    case KeyEvent.KEYCODE_VOLUME_DOWN:
		        audio.adjustStreamVolume(
		            AudioManager.STREAM_MUSIC,
		            AudioManager.ADJUST_LOWER,
		            AudioManager.FLAG_PLAY_SOUND | AudioManager.FLAG_SHOW_UI);
		        return true;
		    case KeyEvent.KEYCODE_BACK:
		           System.out.println("KEYCODE_BACK");
                    if(chestPop!=null)
				       {
					     mFrameLayout.removeView(chestPop);
					     chestPop = null;
					     removeWebViewLua();
					     return true;
			           }
		        break;
		    default:
		        break;
	    }
	    return super.onKeyDown(keyCode, event);
	}
	private static native boolean nativeIsLandScape();
	private static native boolean nativeIsDebug();
	
	public static FrameLayout  getShowView()
	{
		return mFrameLayout;
	}
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		SpecialFactory.getInstance().onNewIntent(intent);
	}

    private static Handler mHandler = new Handler() { 
        @Override  
        public void handleMessage(Message msg) {  
            Util.doTaskInUIThreadCallback(msg.what, msg.arg1, msg.arg2);
            super.handleMessage(msg);  
        }
    };
    public static void doTaskInUIThread(Message msg) {
        mHandler.sendMessage(msg);
    }
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
	    super.onConfigurationChanged(newConfig);
	    SpecialFactory.getInstance().onConfigurationChanged(newConfig);
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
	    super.onRestoreInstanceState(savedInstanceState);
	    SpecialFactory.getInstance().onRestoreInstanceState(savedInstanceState);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
	    super.onSaveInstanceState(outState);
	    SpecialFactory.getInstance().onSaveInstanceState(outState);
	}
}

package com.qufan.pay.sdk;



import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.SmsManager;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import com.qufan.util.XLog;
import android.view.Window;
import android.view.WindowManager;
import android.net.Uri;

import com.qufan.pay.sdk.utils.SdkUtils;
import com.qufan.texas.util.Util;
import com.qufan.util.RHelper;
import com.qufan.config.Common;

import android.widget.PopupWindow;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import com.qufan.texas.util.RelayoutTool;
import android.view.ViewGroup;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.widget.Button;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.view.Gravity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import android.webkit.JsResult;
import android.widget.Toast;
import android.view.MotionEvent;
import android.net.http.SslError;
import android.widget.FrameLayout;


public class PayWebActivity extends Activity {

	private static PayWebActivity sContext = null;
	private static FrameLayout mFrameLayout = null;

	private static String url = "";

	public static Context getContext() {
		Log.e("AppActivity", "sContext"+sContext);
		return sContext;
	}
	public static void setUrl(String uri)
	{
		url = uri;
	}

	private static PopupWindow chestPop;
	
	public static void showWebActivity(String url,float x,float y,float w,float h) {
		if (chestPop != null && chestPop.isShowing()) {
			return;
		}
		Context context = getContext();


		final View popView = View.inflate(Util.context, RHelper.getValue(RHelper.layout, "d_activity"), null);
		RelayoutTool.relayoutViewHierarchy(popView);
		chestPop = new PopupWindow(popView);
		chestPop.setWindowLayoutMode(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		chestPop.setFocusable(true);
		chestPop.setOutsideTouchable(false);
		chestPop.setBackgroundDrawable(new BitmapDrawable());
		chestPop.setHeight((int)(h));
		chestPop.setWidth((int)(w));
		final Button mWebBack = (Button) popView.findViewById(RHelper.getValue(RHelper.id,"events_back_btn"));
		mWebBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				closeWebActivity();
				sContext.finish();
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
		});
		
		mWebView.setWebViewClient(new WebViewClient() {
//			public void onReceivedSslError(WebView view,
//					final SslErrorHandler handler, SslError error) {
//				handler.proceed(); // 接受所有网站的证书
//			}
            @Override
            public void onReceivedSslError(WebView view, final SslErrorHandler handler, SslError error) {
                final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                builder.setMessage("Your security warning message here");
                builder.setPositiveButton("proceed", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        handler.proceed();
                    }
                });
                builder.setNegativeButton("cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        handler.cancel();
                    }
                });
                final AlertDialog dialog = builder.create();
                dialog.show();
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
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				// 如下方案可在非微信内部WebView的H5页面中调出微信支付
				//if (url.startsWith("weixin://wap/pay?")) {
					try{
						Intent intent = new Intent();
						intent.setAction(Intent.ACTION_VIEW);
						intent.setData(Uri.parse(url));
						sContext.startActivity(intent);

					}catch (Exception e){
						// MiscUtil.toastShortShow(mContext, "请安装微信最新版！");
					}
				// }else{
				// 	view.loadUrl(url);
				// }
				return true;
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

		chestPop.setOnDismissListener(new PopupWindow.OnDismissListener() {
	        @Override
	        public void onDismiss() {
	        	closeWebActivity();
	        	sContext.finish();
	        }
	    });
 
		mWebView.loadUrl(url);

		chestPop.showAtLocation(mFrameLayout, Gravity.CENTER | Gravity.TOP, 0,
				(int) y);
		Log.e("AppActivity", url);
	}
	public static void closeWebActivity(){
		if(chestPop!=null){
			
			PopupWindow temp=chestPop;
			chestPop = null;
			temp.dismiss();
		}
		url = "";
	}

	@Override
	public void finish() {
		super.finish();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Window window = getWindow();
		window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
				| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
				WindowManager.LayoutParams.FLAG_FULLSCREEN
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		WindowManager.LayoutParams wl = window.getAttributes();
		wl.alpha = 1.0f;// 这句就是设置窗口里控件的透明度的．０.０全透明．１.０不透明．
		window.setAttributes(wl);

		sContext = this;

		// FrameLayout
		ViewGroup.LayoutParams framelayout_params = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.MATCH_PARENT,
				ViewGroup.LayoutParams.MATCH_PARENT);
		mFrameLayout = new FrameLayout(this);
		mFrameLayout.setLayoutParams(framelayout_params);
		setContentView(mFrameLayout);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
	 super.onWindowFocusChanged(hasFocus);
	 if(hasFocus){
		if(url != "")
		{
			showWebActivity(url,0, 0,1920, 1080);
		}
	 }

	}
}

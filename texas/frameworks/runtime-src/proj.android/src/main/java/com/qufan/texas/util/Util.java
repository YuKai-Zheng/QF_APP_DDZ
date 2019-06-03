package com.qufan.texas.util;

import java.io.File;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Set;
import java.util.HashSet;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.DownloadManager;
import android.app.DownloadManager.Query;
import android.app.DownloadManager.Request;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.os.Vibrator;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
//import cn.jpush.android.api.JPushInterface;
//import cn.jpush.android.api.TagAliasCallback;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.NetworkInfo.State;

import com.github.kevinsawicki.http.HttpRequest;
//import com.qufan.baidu.BaiduPinXuan;
import com.qufan.config.Common;
import com.qufan.ddz.uploadphoto.UploadPhotoUtil;
import com.qufan.login.QQ.QQLogin;
import com.qufan.login.wx.WeiXinLogin;
import com.qufan.pay.sdk.TexasConstant;
import com.qufan.pay.UnitySDKFactory;
import com.qufan.pay.unity_pay.BillParams;
import com.qufan.pay.sdk.utils.Md5Coder;
import com.qufan.special.sdk.SpecialConstant;
import com.qufan.special.sdk.SpecialFactory;
import com.qufan.util.RHelper;
import com.umeng.analytics.MobclickAgent;
import android.telephony.TelephonyManager;
import com.qufan.util.XLog;
// import com.alibaba.sdk.android.feedback.impl.FeedbackAPI;
// import com.alibaba.sdk.android.feedback.util.IUnreadCountCallback;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager.WifiLock;
import android.net.wifi.ScanResult;
import com.qufan.texas.util.ZXingUtils;
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;

public class Util {
	public static int PayCallBack;
	public static Activity context = null;
	public static int blue_choose_num = 0;

    public static int MSG_COOLPAY_LOGIN = 0;
    public static int MSG_COOLPAY_LOGOUT = 1;

	static JSONObject json = null;
	static String payHost_util;
	static String source_util;
	static String[] pay_title;
	private static int exitLucb;
	private static PopupWindow chestPop;
	
	private static String TAG = "Texas-Util";
	private static TelephonyManager telephonyManager = null;

	public static Set jpushTags = null;
    private static SpeechToText m_stt = null;

	static Handler handler = new Handler() {
		public void dispatchMessage(android.os.Message msg) {
			switch (msg.what) {
			case Common.NOTIFY_QUIT_WEB: {
				// if (DActivity.myActivity!=null) {
				// DActivity.myActivity.dismiss();
				// DActivity.myActivity = null;
				// }
				AppActivity.closeWebActivity();
			}
				break;
			case Common.NOTIFY_SHOW_WEB: {
				Object[] objects = (Object[]) msg.obj;
				// DActivity.showActivity((String)objects[0],(Float)objects[1],(Float)objects[2],
				// (Float)objects[3],(Float)objects[4],(Integer)objects[5]);
				AppActivity.showWebActivity(context, (String) objects[0],
						(Float) objects[1], (Float) objects[2],
						(Float) objects[3], (Float) objects[4],
						(Integer) objects[5],(Integer) objects[6]);
			}
				break;
			}
		}
	};

	public static String getBaseVersion() {

		try {
			PackageManager manager = context.getPackageManager();
			PackageInfo info = manager.getPackageInfo(context.getPackageName(),
					0);
			String version = info.versionName;
			Log.d(TAG, "getBase Version from android , version = " + version);
			return version;
		} catch (Exception e) {
			e.printStackTrace();

		}
		return "0.0.0";
	}

	public static boolean isDebugEnv() {
		//return RHelper.isDebug();
		return false;
	}
	public static void exitCallback(){


		Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
						{
                           @Override
                           public void run() {
                           	 Log.d("AppActivity", "runOnGLThread ");
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(exitLucb, "1");
                             Log.d("AppActivity", "runOnGLThread over");
                          }
                      }); 
	}
	public static void exitDialog(final String title, final String sure,
			final String cancel, final int luaCB) {
		try {
			Log.d(TAG, title);
			Log.d(TAG, sure);
			Log.d(TAG, cancel);

			context.runOnUiThread(new Runnable() {
				public void run() {
					if(SpecialFactory.getInstance().onQuit(title, sure, cancel, luaCB)){
						return;
					}
					new AlertDialog.Builder(context)
							.setTitle(title)
							.setPositiveButton(sure,
									new DialogInterface.OnClickListener() {
										public void onClick(
												DialogInterface dialog,
												int which) {


													Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
													{
                          							 @Override
                           							public void run() {

														Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaCB, "1");
                          							}
                     							 }); 

											Tools.exitsure(context);
										}
									})

							.setNegativeButton(cancel,
									new DialogInterface.OnClickListener() {
										public void onClick(
												DialogInterface dialog,
												int which) {
											Log.d(TAG,
													" you cancel exit dialog !");
													Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
													{
                          							 @Override
                           							public void run() {

														Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaCB, "0");
                          							}
                     							 }); 
										}
									}).show();

				}
			});

		} catch (Exception e1) {
			e1.printStackTrace();
		}
	}

	
	/**
	 * 直接退出游戏
	 */
	public static void exitGame() {
		Tools.exitsure(context);
	}

	public static void restartGame() {
		exitGame();
	}
	public static String getDeviceId() {
		return  "IMEI:" + DeviceUtil.getDeviceID(context);
	}
	public static String getRegInfo() {
		JSONObject registInfo = new JSONObject();
		try {
            String uuidPrefix = context.getPackageName() + ":";
			String uuid = uuidPrefix + DeviceUtil.deviceUuid.toString();
			registInfo.put("uuid", uuid);
			registInfo.put("mac_addr", PackageUtil.getTerminalSign(context));
			String device_id = Util.getDeviceId();
			registInfo.put("device_id", device_id);
			registInfo.put("app_name", PackageUtil.getAppname(context));
			registInfo.put("channel",
					PackageUtil.getConfigString(context, "UMENG_CHANNEL"));
			registInfo.put("version", PackageUtil.getVersionCode(context));
			registInfo.put("pkg_name", PackageUtil.getpackageName(context));
			String sign = Md5Coder.md5(Common.UNITY_PAY_SECRET + "|"
					+ uuid + "|" + device_id);
			registInfo.put("sign", sign);
			registInfo.put("nick", DeviceUtil.deviceModel.toString());
			registInfo.put("deviceSystemVersion", DeviceUtil.deviceVersion.toString());
		} catch (Throwable e) {
			e.printStackTrace();
		}
		return registInfo.toString();
	}

	public static String getKey() {
		return Common.UNITY_PAY_SECRET;
	}

	/**
	 * 用户点击拍照
	 * 
	 * @param cachePath
	 *            缓存目录
	 * @param key
	 *            密码
	 * @param url
	 *            上传路径
	 * @param uin
	 *            账号
	 * @param cb
	 *            回调方法
	 * @param type
	 *            1 拍照 2本地上传
	 */
	public static void uploadPhoto(String cachePath, String key, String url,
			int uin, int cb, int type) {
		switch (type) {
		case 1:
			UploadPhotoUtil.getInstance().getCamera(cachePath, key, url, uin,
					cb,true);// 拍照上传
			break;
		case 2:
			UploadPhotoUtil.getInstance()
					.getLocal(cachePath, key, url, uin, cb,true);// 本地照片
			break;
	
		case 3:
			UploadPhotoUtil.getInstance().getCamera(cachePath, key, url, uin,
					cb,false);// 拍照上传
			break;
		case 4:
			UploadPhotoUtil.getInstance()
					.getLocal(cachePath, key, url, uin, cb,false);// 本地照片
			break;
		}
	}

	/**
	 * url=self.url,x=x,y=y,w=w,h=h, cb
	 */
	public static void showWebView(String url, float x, float y, float w,
			float h, int cb,int cb2) {
		Message message = handler.obtainMessage(Common.NOTIFY_SHOW_WEB);
		message.obj = new Object[] { url, x, y, w, h, cb ,cb2};
		message.sendToTarget();
	}

	public static void playVibrate(int milliseconds) {
		Vibrator vib = (Vibrator) Util.context
				.getSystemService(Service.VIBRATOR_SERVICE);
		vib.vibrate(milliseconds);
	}

	public static void removeWebView() {
		handler.sendEmptyMessage(Common.NOTIFY_QUIT_WEB);
		// UmengUpdateAgent.setUpdateOnlyWifi(false);
		// UmengUpdateAgent.update(Util.context);
	}

	/**
	 * local jsonTable = {dxType=dxType,ydType=ydType,ltType=ltType,userId =
	 * Cache.user.uin, item_id= shopInfo.item_id,desc=shopInfo.desc,extra=
	 * shopInfo.extra,cost = shopInfo.cost, extra_desc =
	 * shopInfo.extra_desc,gold = shopInfo.gold,payType = shopInfo.payType}
	 * 
	 * @param payJson
	 */
	public static void allPay(String payJson,String payHost,String source, int luaCB) {
		Util.PayCallBack = luaCB;
		try {
			JSONObject billJson = new JSONObject(payJson);
			BillParams billParams = new BillParams();

			billParams.channel = getChannel();
			billParams.appVersion = getVersionCode();
			billParams.ref = Tools.getJsonInt(billJson, "ref");
			billParams.amt = Tools.getJsonFloat(billJson, "cost");
			billParams.userid = Tools.getJsonString(billJson, "user_id");
			billParams.itemID = Tools.getJsonString(billJson, "item_id");
			billParams.billType = Tools.getJsonInt(billJson, "bill_type");

			// 额外的数据
			billParams.extra.put("item_name", Tools.getJsonString(billJson, "name_desc"));
			billParams.extra.put("userName", Tools.getJsonString(billJson, "username"));
			billParams.extra.put("userQfOpenId", Tools.getJsonString(billJson, "openid"));
			billParams.extra.put("userDiamond", Tools.getJsonString(billJson, "diamond"));
			billParams.extra.put("proxy_item_id", Tools.getJsonString(billJson, "proxy_item_id"));
			billParams.extra.put("login_type", Tools.getJsonString(billJson, "login_type"));

			UnitySDKFactory.getInstance().startPay((AppActivity)Util.context, billParams, payHost, source, luaCB);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * umeng 统计通用接口
	 * 
	 * @param analyticsKey
	 * @param analyticsValue
	 */
	public static void umengStatistics(String analyticsKey,
			String analyticsValue, int type) {
		Log.e("umengStatistics", "umengStatistics == " + analyticsKey
				+ " analyticsValue= " + analyticsValue);
		if (type == 0) {
			if (analyticsValue.trim().length() == 0) {
				MobclickAgent.onEvent(Util.context, analyticsKey);
			} else {
				MobclickAgent.onEvent(Util.context, analyticsKey,
						analyticsValue);
			}
		} else {
			if (analyticsValue.trim().length() == 0)
				analyticsValue = "0";
			MobclickAgent.onEventValue(Util.context, analyticsKey, null,
					Integer.parseInt(analyticsValue));
		}

	}

	public static String getExternalPath() {
		String path = AppActivity.getSDCardPath();
		if (path.equals(null)) {
			return "nil";
		} else {
			String eps = path + File.separator + context.getPackageName();
			File epdir = new File(eps);
			if (!epdir.exists()) {
				epdir.mkdir();
			}
			return eps;
		}
	}

	/**
	 * 申请美女认证
	 * 
	 * @param livePhoto
	 *            生活照路径
	 * @param spotPhoto
	 *            自拍照片路径
	 * @param url
	 *            上传url
	 * @param key
	 *            密码
	 * @param uin
	 *            账号
	 * @param cb
	 *            回调函数
	 */
	public static void requestApplyAuth(String livePhoto, String spotPhoto,
			String url, String key, int uin, int cb) {
		Log.e("Util","requestApplyAuth  livePhoto:"+livePhoto+" ~spotPhoto:"+spotPhoto+" ~url"+url+" ~key"+key+
				" ~uin"+uin+" ~cb"+cb);
		Tools.requestApplyAuth(livePhoto, spotPhoto, url, key, uin, cb);
	}

	/**
	 * 执行更新
	 * 
	 * @param url
	 */
	private static long __downloadID = 0;
	private static DownloadManager downloadManager; 
	public static BroadcastReceiver receiver = new BroadcastReceiver() {
		public void onReceive(Context context, Intent intent) {
			Log.d(TAG, " -- down load success --" + __downloadID + " " + intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, 0));

			if (__downloadID == intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, 0)) {

				Query myDownloadQuery = new Query();
				myDownloadQuery.setFilterById(__downloadID);

				Cursor myDownload = downloadManager.query(myDownloadQuery);
				if (myDownload.moveToFirst()) {

					int fileUriIdx = myDownload.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI);

					String fileUri = myDownload.getString(fileUriIdx);

					Log.d(TAG, " download file uri " + fileUri);
					Intent installIntent = new Intent();
					installIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
					installIntent.setAction(android.content.Intent.ACTION_VIEW);
					installIntent.setDataAndType(Uri.parse(fileUri), "application/vnd.android.package-archive");
					context.startActivity(installIntent);
				}
				myDownload.close();

			}
		}
	};
	public static void updateGame(String url) {
		/*Intent intent = new Intent("android.intent.action.VIEW", Uri.parse(url));
		context.startActivity(intent);
		exitGame();*/
		downloadManager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
		 context.registerReceiver(receiver, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));  
		try {

			Request req = new Request(Uri.parse(url));
			String destDir = "qufan.ddz";
			String destFileName = "ddz" + new Date(System.currentTimeMillis()).getTime() + ".apk";

			req.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE | DownloadManager.Request.NETWORK_WIFI);
			req.setTitle(PackageUtil.getAppname(context));
			req.setDescription("正在下载"+PackageUtil.getAppname(context)+"最新版");
			req.setDestinationInExternalPublicDir(destDir, destFileName);

			__downloadID = downloadManager.enqueue(req);

			//IntentFilter filter = new IntentFilter();  
           // filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);  
		} catch (Exception e) {
		}
	}

	public static void bindPushAlias(String alias) {
		PushServiceFactory.getCloudPushService().bindAccount(alias, new CommonCallback() {
			@Override
			public void onSuccess(String s) {
				XLog.e("绑定别名成功:"+s);
			}

			@Override
			public void onFailed(String errorCode, String errorMsg) {
			}
		});
	}

	public static void pushAddTag() {

	}

	public static void pushDeleteTag() {

	}

	public static String md5(String password) {
		return Md5Coder.md5(password);
	}

	public static String getLang() {  
		
		String language = Locale.getDefault().toString();
		if(language.compareTo("zh_CN") == 0 ){//中文
			return "cn";
		}else if(language.compareTo("th_TH") == 0){//泰文
			return "cn";
		}else if(language.compareTo("en_GB") == 0){//英文
			return "cn";
		}else if(language.compareTo("ja_JP") == 0){//日文
			//return "jp";
		}
		
		return "cn";
		//return language == "zh_CN" ? "cn" : language;
	}

	public static String getHotUpdateInfo() {
		JSONObject ret = new JSONObject();
		try {
			ret.put("baseversion", PackageUtil.getVersionCode(context));
			ret.put("chid",
					PackageUtil.getConfigString(context, "UMENG_CHANNEL"));
			ret.put("pkgname", getPKGName());
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return ret.toString();
	}

    public static int getVersionCode() {
        return PackageUtil.getVersionCode(context);
    }

    public static String getChannel() {
        return PackageUtil.getConfigString(context, "UMENG_CHANNEL");
    }

	public static Object getPKGName() {
		return Util.context.getPackageName();
	}

	/**上报错误*/
	public static void uploadError(String uploadJson)
	{
		Log.e(" android post error","error");
		JSONObject upload;
		try {
			upload = new JSONObject(uploadJson);
			final String host = Tools.getJsonString(upload, "host");
			final String content = Tools.getJsonString(upload, "content");
			final String channel = Tools.getJsonString(upload, "channel");
			final String uid = Tools.getJsonString(upload, "uid");
			final String debug = Tools.getJsonString(upload, "debug");
			// 获取packagemanager的实例  
			PackageManager packageManager = Util.context.getPackageManager();  
	        // getPackageName()是你当前类的包名，0代表是获取版本信息  
	        PackageInfo packInfo = packageManager.getPackageInfo(Util.context.getPackageName(),0);  
	        final String version = ""+packInfo.versionCode;  

			new Thread(){
				@Override
				public void run() {
					HashMap<String, String> map = new HashMap<String, String>();

					map.put("content", content);
					map.put("channel", channel);
					map.put("uin", uid);
					map.put("debug", debug);
					map.put("version", version);
					map.put("os", "android");
					//String body = HttpRequest.post(url).form(entry, charset);
					final String url = host;
					String body = HttpRequest.get(url, map, true).body();
					Log.e("httpGetRequest:", "receive = " + body);

				}

			}.start();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	/**在测试服时保存错误到本地**/
	public static void saveErrorToLocal(String error) {
		String sdPath = AppActivity.getSDCardPath();
		if (sdPath != null) {
			try {
				String errorFile = sdPath+"/error.txt";
				BufferedWriter bw = new BufferedWriter(new FileWriter(errorFile, true));
				bw.write(error);
				bw.write("\r\n");
				bw.flush();
				bw.close();
			} catch (Exception e) {
	            e.printStackTrace();
	        }
		}
	}

	// 登录
	public static void sdkAccountLogin(int type, int cb, int gameOverCb) {
		String str =  Integer.toString(type);
		XLog.d("Lua-sdkAccountLoginsdkAccountLoginsdkAccountLoginsdkAccountLogin="+str);
		if (type == 3) {
			WeiXinLogin.getInstance(context).init(cb);
		} else if (type == 1) {
			QQLogin.getInstance(context).init(cb);
		} else {
			SpecialFactory.getInstance().login(type, cb, gameOverCb);
		}
	}

	public static void sdkLogout(){
		SpecialFactory.getInstance().logout();
	}

	public static void sdkAccountSwitch(int type, int cb, int gameOverCb){
		SpecialFactory.accountSwitch(type, cb, gameOverCb);
	}

	//判断登录
    public static int checkLogin(){
    	return SpecialFactory.getInstance().checkLogin();
    }

	public static void sdkUpdatePlayerInfo(String playerInfoJson){
		SpecialFactory.getInstance().doSdkGetUserInfoByCP(playerInfoJson);
	}

	public static void sdkShare(String paramsJson, int type, int cb) {
		if (type == 1) {
			QQLogin.getInstance(context).shareToQQ(paramsJson, cb);
		} else if (type == 3) {
			WeiXinLogin.getInstance(context).shareToWX(paramsJson, cb);
		} else {
			SpecialFactory.getInstance().share(paramsJson, type, cb);
		}
	}

	public static String gameSpotLogin(){
		return TexasConstant.GAME_SPOT_USER_ID;//在最开始的时候就已经初始化过了
	}

    public static boolean isSmsVerificationEnabled() {
    	return false;
    }

	public static void getSmsVerificationCode(String zone, String phone, int cb) {
	}

	public static void getVoiceVerificationCode(String zone, String phone, int cb) {
	}

    public static void doTaskInUIThreadCallback(int msg, int arg1, int arg2) {

    }

	public static int getMusicSet(){
		return TexasConstant.MUSIC_SET;
	}

	//获取运营商类型
	public static int getNetworkType(){
		return Tools.getIMSI(context);
	}
   /**
   * @content 好友界面第4项，发送短信
   * @param content
   */
	public static void sendSms(String content){
		XLog.d("--------sendSms content ="+ content);
		Intent sendIntent = new Intent(Intent.ACTION_VIEW);
		sendIntent.putExtra("sms_body", content);
		sendIntent.setType("vnd.android-dir/mms-sms");
		Util.context.startActivity(sendIntent);
	}
	// 获取微信APPID
	public static String getWxAppId() {
		XLog.e("--------wxAppIdwxAppIdwxAppIdwxAppId content ="+PackageUtil.getAppMetadata(context, "wxAppId"));
		return PackageUtil.getAppMetadata(context, "wxAppId");
  	}
  	// 获取微信SECRET:现在APPSecret不在客户端配置
  	// public static String getWxSecret() {
  	// 	String _wxSecret = PackageUtil.getAppMetadata(context, "wxAppSecret");
  	// 	return _wxSecret.substring(2);
  	// }
	// 获取QQ APPID
	public static String getQqAppId() {
		String _qqAppId = PackageUtil.getAppMetadata(context, "qqAppId");
		return _qqAppId.substring(2);
  	}
  	// 获取QQ SECRET
  	public static String getQqSecret() {
  		return PackageUtil.getAppMetadata(context, "qqAppSecret");
  	}
  	//获取WiFi信号强度    
  	public static int getWifiSignal() {
	  	if (context != null) {  
	        // Wifi的连接速度及信号强度：
	        int strength = 0;
	        WifiManager wifiManager = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);  
	        // WifiInfo wifiInfo = wifiManager.getConnectionInfo();
	        WifiInfo info = wifiManager.getConnectionInfo();
	        if (info.getBSSID() != null) {
	            // 链接信号强度，5为获取的信号强度值在5以内
	             strength = WifiManager.calculateSignalLevel(info.getRssi(), 5);
	            // 链接速度
	            int speed = info.getLinkSpeed();
	            // 链接速度单位
	            String units = WifiInfo.LINK_SPEED_UNITS;
	            // Wifi源名称
	            String ssid = info.getSSID();
	        }
	//        return info.toString();
	        return strength;
	     }  
	     return -200; 
  	}
  	public static int isEnabledWifi() {
	  	if (context != null) {  
	         ConnectivityManager mConnectivityManager = (ConnectivityManager) context  
	                 .getSystemService(Context.CONNECTIVITY_SERVICE);  
	         NetworkInfo mWiFiNetworkInfo = mConnectivityManager  
	                 .getNetworkInfo(ConnectivityManager.TYPE_WIFI);  
	         if (mWiFiNetworkInfo != null) {  
	         	if (mWiFiNetworkInfo.isAvailable() && mWiFiNetworkInfo.getState() == State.CONNECTED) {
	         		return 1;
	         	} else {
	         		return 0;
	         	}
	         }  
	     }  
	     return 0; 
  	}
  	public static int isEnabledGPRS() {     
	    if (context != null) {  
	        ConnectivityManager mConnectivityManager = (ConnectivityManager) context  
	                 .getSystemService(Context.CONNECTIVITY_SERVICE);  
	        NetworkInfo mMobileNetworkInfo = mConnectivityManager  
	                 .getNetworkInfo(ConnectivityManager.TYPE_MOBILE);  
	        if (mMobileNetworkInfo != null) {  
	         	if (mMobileNetworkInfo.isAvailable() && mMobileNetworkInfo.getState() == State.CONNECTED) {
	         		return 1;
	         	} else {
	         		return 0;
	         	}
	        }  
	    }  
	    return 0;
  	}
	public static int getBatteryLevel() {
		return DeviceUtil.batteryPower;
	}
    
    //开始语音识别
    public static int startVoiceRecognition(int cb) {
        if (m_stt == null) {
            m_stt = new SpeechToText(context);
        }
        return m_stt.start(cb);
    }
    //结束语音识别
    public static void finishVoiceRecognition() {
        if (m_stt != null) {
            m_stt.finish();
        }
    }
    //取消语音识别
    public static void cancelVoiceRecognition() {
        if (m_stt != null) {
            m_stt.cancel();
        }
    }
    //获取语音音量
    public static int getVoiceRecognitionVolume() {
        if (m_stt != null) {
            return m_stt.getVolume();
        }
        return 0;
    }

    // 生成二维码
    public static void createQRCode(String paramsJson) {
		JSONObject newsJson;
		try {
			newsJson = new JSONObject(paramsJson);
			String qrCodeStr = Tools.getJsonString(newsJson, "qrCodeStr");
			String fileName = Tools.getJsonString(newsJson, "qyCodeFileName");
			int size = Tools.getJsonInt(newsJson, "size");
			Bitmap bitmap = ZXingUtils.createQRImage(qrCodeStr, size, size);
			String filePath = getExternalPath();
			ZXingUtils.saveImageToStorage(filePath ,bitmap, fileName);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    // 版本更新
    public static void versionUpdate(String paramsJson) {
		JSONObject newsJson;
		try {
			newsJson = new JSONObject(paramsJson);
			String url = Tools.getJsonString(newsJson, "url");
			Uri uri = Uri.parse(url);
			Intent intent = new Intent(Intent.ACTION_VIEW, uri);
			Util.context.startActivity(intent);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void print_log(String context) {
    	XLog.d("[Lua-Test-Print]=> " + context);
    }

    public static void openWXMiniProgram(int uin) {
        IWXAPI api = WXAPIFactory.createWXAPI(context, getWxAppId(), false);
        WXLaunchMiniProgram.Req req = new WXLaunchMiniProgram.Req();

        req.userName = "gh_9a3e0d76b08a";
        req.path = String.format("pages/xxx/xxx?from=CN_AD_APPWYDDZ&uin=%d", uin);//需要传参数时使用
        req.miniprogramType = 0;// 正式版:0，测试版:1，体验版:2
        api.sendReq(req);
    }

	public static void registerWXAPP() {
		WeiXinLogin.getInstance(context);
	}
}


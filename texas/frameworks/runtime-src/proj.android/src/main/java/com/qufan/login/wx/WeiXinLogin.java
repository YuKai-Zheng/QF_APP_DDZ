package com.qufan.login.wx;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONArray;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.widget.Toast;
import android.os.Environment;

import com.qufan.util.XLog;

import com.qufan.texas.R;
import com.qufan.texas.util.Tools;
import com.qufan.texas.util.Util;
import com.qufan.texas.util.BmpUtil;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXImageObject;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.qufan.texas.util.Util;
import com.qufan.texas.util.PackageUtil;


import java.io.File;

public class WeiXinLogin {
	static private WeiXinLogin _instance;
	// IWXAPI 是第三方app和微信通信的openapi接口
	public static IWXAPI api;
	private Context _context;
	public static String APP_ID = null; //"wx4c227b86782d6ff1";
	private static final String SDCARD_ROOT = Environment.getExternalStorageDirectory().getAbsolutePath();
	private static final int THUMB_SIZE = 150;
	private int _cb;

	public void init(int cb) {
//		_context = context;
		_cb = cb;
//		if (api == null) {
//			api = WXAPIFactory.createWXAPI(context, APP_ID, false);
//		}
//		if (!api.isWXAppInstalled()) {
//			Toast.makeText(_context, "请安装微信", Toast.LENGTH_SHORT).show();
//			return;
//		}
//		api.registerApp(APP_ID);
		SendAuth.Req req = new SendAuth.Req();
		req.scope = "snsapi_userinfo";
		req.state = "wechat_sdk_gushen";
		XLog.d("===============api.sendReq=================");
		api.sendReq(req);
	}
	private String msg = "";
	public void getCodeResult(final BaseResp resp) {
		msg = "";
		XLog.d("Lua-getCodeResult");
		JSONObject info = new JSONObject();
		try {
			info.put("type", 3);
			if (resp.getType() == 1) { // 登录验证
				XLog.d("Lua-getCodeResult1");
				if (resp.errCode == 0) {// 初始化并登录成功
					XLog.d("Lua-getCodeResult2");
					info.put("code", ((SendAuth.Resp) resp).code);
				} else if (resp.errCode == -4) {
					msg = "安装包签名与平台不一致";
					XLog.d("Lua-getCodeResult3");
				} else {
					msg = "获取微信信息失败";
					XLog.d("Lua-getCodeResult4");
				}
			} else if (resp.getType() == 2) { // 分享 SendMessageToWX
				if (resp.errCode == 0) {// 初始化并登录成功
					info.put("code", ((SendMessageToWX.Resp) resp).errCode);
					msg = "分享成功";
				} else if (resp.errCode == BaseResp.ErrCode.ERR_USER_CANCEL) {//取消
					msg = "分享取消";
				} else if (resp.errCode == BaseResp.ErrCode.ERR_AUTH_DENIED) {//拒绝
					msg = "分享拒绝";
				} else {//返回
					msg = "分享返回";
				}
			}

		} catch (JSONException e) {
			e.printStackTrace();
		}
		if( msg != "" ){
		((Activity)_context).runOnUiThread(new Runnable() {   
                    @Override   
                        public void run() {   
                          Toast.makeText(_context, msg, Toast.LENGTH_SHORT).show();
                        }   
         });
		}
		Cocos2dxLuaJavaBridge.callLuaFunctionWithString(_cb, info.toString());
		Cocos2dxLuaJavaBridge.releaseLuaFunction(_cb);
	}

	public void shareToWX(String paramsJson, int cb) {
		_cb = cb;
		JSONObject newsJson;
		try {
			newsJson = new JSONObject(paramsJson);
			int share = Tools.getJsonInt(newsJson, "share");
			if (share == 1) { // 只分享图片
				this.shareLocalImageToWX(newsJson);
			} else if (share == 2) { // 图文链接
				this.shareWebpageToWX(newsJson);
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void shareLocalImageToWX(JSONObject newsJson) {
		String localImagePath = Tools.getJsonString(newsJson, "localPath");
		// String localFullPath = SDCARD_ROOT + "/" + localImagePath;
		File file = new File(localImagePath);
		if (!file.exists()) {
			Toast.makeText((Activity)_context, "image not exists path=" + localImagePath, Toast.LENGTH_LONG).show();
			return;
		}
		Bitmap bmp = BitmapFactory.decodeFile(localImagePath);
		WXImageObject imgObj = new WXImageObject(bmp);
		// imgObj.setImagePath(localImagePath);

		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = imgObj;

		Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
		bmp.recycle();
		msg.thumbData = BmpUtil.bmpToByteArray(thumbBmp, true);

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("img");
		req.message = msg;

		int intScene = Tools.getJsonInt(newsJson, "scene");
		req.scene = intScene == 2?SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
		api.sendReq(req);

//		((Activity)context).finish();
	}

	private void shareWebpageToWX(JSONObject newsJson) {
		String localImagePath = Tools.getJsonString(newsJson, "localPath");
		// String localFullPath = SDCARD_ROOT + "/" + localImagePath;
		File file = new File(localImagePath);
		if (!file.exists()) {
			if (!file.exists()) {
			Toast.makeText((Activity)_context, "image not exists path=" + localImagePath, Toast.LENGTH_LONG).show();
			return;
			}

		}
		int intScene = Tools.getJsonInt(newsJson, "scene");

		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = Tools.getJsonString(newsJson, "targetUrl");//"http://www.baidu.com";
		WXMediaMessage msg = new WXMediaMessage(webpage);
		if (intScene == 2) {
			msg.title = Tools.getJsonString(newsJson, "description");//Tools.getJsonString(newsJson, "title") + " " + Tools.getJsonString(newsJson, "description");
		} else {
			msg.title = PackageUtil.getAppname(_context);//"WebPage Title : share To WX";
		}
		msg.description = Tools.getJsonString(newsJson, "description");//"Description : share To WX";

		Bitmap bmp = BitmapFactory.decodeFile(localImagePath);
		Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
		bmp.recycle();
		msg.thumbData = BmpUtil.bmpToByteArray(thumbBmp, true);

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;

		req.scene = intScene == 2?SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
		api.sendReq(req);

//		((Activity)context).finish();
	}

	public void registerApp(Context context) {
		_context = context;
		if (api == null) {
			api = WXAPIFactory.createWXAPI(context, APP_ID, false);
		}
		if (!api.isWXAppInstalled()) {
			XLog.e("not install WeChat");
			((Activity)context).runOnUiThread(new Runnable() {   
                    @Override   
                        public void run() {   
                          Toast.makeText(_context, "请先安装微信", Toast.LENGTH_SHORT).show();
                        }   
                    });
			return;
		}
		api.registerApp(APP_ID);
	}

	public static WeiXinLogin getInstance(Context context) {
		if (_instance == null)
			_instance = new WeiXinLogin();
			APP_ID = Util.getWxAppId();
			_instance.registerApp(context);
		return _instance;
	}
	public static WeiXinLogin getInstance() {
		if (_instance == null)
			_instance = new WeiXinLogin();
		return _instance;
	}
	private String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}
}

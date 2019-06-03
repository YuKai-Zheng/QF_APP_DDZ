package com.qufan.login.QQ;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.provider.SyncStateContract;
import android.util.Log;

import java.io.File;
import android.os.Environment;
import android.widget.Toast;
import com.qufan.texas.util.PackageUtil;
import com.qufan.texas.util.Util;
import com.qufan.util.XLog;

import com.qufan.texas.util.Tools;
import com.tencent.connect.common.Constants;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;
import com.tencent.connect.share.QQShare;

public class QQLogin {
	public static String AppId = null; //"1104538317";
	public static Tencent mTencent;
	public static String shareType;
	private String SCOPE = "get_user_info,add_t,get_simple_userinfo";
	private static Context _context = null;
	private static final String SDCARD_ROOT = Environment.getExternalStorageDirectory().getAbsolutePath();
	private static int _shareHandler = -1;
	private static int _loginHandler = -1;

	public void init(final int cb) {
		// if (!mTencent.isSessionValid()) {
		_loginHandler = cb;
		mTencent.login((Activity)_context, SCOPE, qqLoginListener);
		// }
	}

    IUiListener qqLoginListener = new BaseUiListener() {
		@Override
		protected void doComplete(JSONObject values) {
			JSONObject info = new JSONObject();
			try {
				if (values.has("openid") && values.has("access_token")) {
					info.put("type", 1);
					info.put("token", values.get("access_token"));
					info.put("openid", values.get("openid"));
					info.put("date", values.get("expires_in"));				
				} else
				{
					((Activity)_context).runOnUiThread(new Runnable() {   
		                @Override   
		                    public void run() {   
		                      Toast.makeText(_context, "获取QQ信息失败", Toast.LENGTH_SHORT).show();
		                    }   
			         });
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(_loginHandler,
					info.toString());
			Cocos2dxLuaJavaBridge.releaseLuaFunction(_loginHandler);
		}

		@Override
		public void onError(UiError e) {
			((Activity)_context).runOnUiThread(new Runnable() {   
                @Override   
                    public void run() {   
                      Toast.makeText(_context, "QQ登录失败", Toast.LENGTH_SHORT).show();
                    }   
	         });
			Cocos2dxLuaJavaBridge.releaseLuaFunction(_loginHandler);
		}

		@Override
		public void onCancel() {
			((Activity)_context).runOnUiThread(new Runnable() {   
                @Override   
                    public void run() {   
                      Toast.makeText(_context, "取消登录", Toast.LENGTH_SHORT).show();
                    }   
	         });
			Cocos2dxLuaJavaBridge.releaseLuaFunction(_loginHandler);
		}
    };
    public IUiListener getQQLoginListener() {
    	return qqLoginListener;
    }
	static private QQLogin _instance = null;

	private void registerApp(Context context) {
		AppId = Util.getQqAppId();
		_context = context;
		mTencent = Tencent.createInstance(AppId, context);
	}
	public static QQLogin getInstance(Context context) {
		if (_instance == null) {
			_instance = new QQLogin();
			_instance.registerApp(context);
		}
		return _instance;
	}
	public static QQLogin getInstance() {
		return _instance;
	}

    IUiListener qqShareListener = new BaseUiListener() {
        @Override
        public void onCancel() {
			JSONObject info = new JSONObject();
			try {
				info.put("result", "cancel");
				info.put("share", shareType);
			} catch (JSONException je) {
				je.printStackTrace();
			}
			((Activity)_context).runOnUiThread(new Runnable() {   
                @Override   
                    public void run() {   
                      Toast.makeText(_context, "取消分享", Toast.LENGTH_SHORT).show();
                    }   
	         });
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(_shareHandler,
				info.toString());
			Cocos2dxLuaJavaBridge.releaseLuaFunction(_shareHandler);
        }
        @Override
        public void onComplete(Object response) {				
        	JSONObject info = new JSONObject();
			try {
				info.put("result", "success");
				info.put("share", shareType);
			} catch (JSONException je) {
				je.printStackTrace();
			}
			((Activity)_context).runOnUiThread(new Runnable() {   
                @Override   
                    public void run() {   
                      Toast.makeText(_context, "分享成功", Toast.LENGTH_SHORT).show();
                    }   
	         });
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(_shareHandler,
					info.toString());
			Cocos2dxLuaJavaBridge.releaseLuaFunction(_shareHandler);
        }
        @Override
        public void onError(UiError e) {
			JSONObject info = new JSONObject();
			try {
				info.put("result", "error");
				info.put("share", shareType);
			} catch (JSONException je) {
				je.printStackTrace();
			}
			((Activity)_context).runOnUiThread(new Runnable() {   
                @Override   
                    public void run() {   
                      Toast.makeText(_context, "分享失败", Toast.LENGTH_SHORT).show();
                    }   
	         });
			Cocos2dxLuaJavaBridge.callLuaFunctionWithString(_shareHandler,
				info.toString());
			Cocos2dxLuaJavaBridge.releaseLuaFunction(_shareHandler);
        }
    };

	public void shareLocalImageToQQ(JSONObject paramsJson) {
		shareType = "1";
		final Bundle params = new Bundle();
		String localImagePath = Tools.getJsonString(paramsJson, "localPath");
		File file = new File(localImagePath);
		if (!file.exists()) {
			_shareHandler = -1;
			return;
		}
		String newPath = SDCARD_ROOT + "/share.jpg";
		if (!Tools.copyFile(localImagePath, newPath)) {
			_shareHandler = -1;
			return ;
		}

		params.putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, newPath);
		params.putString(QQShare.SHARE_TO_QQ_APP_NAME, PackageUtil.getAppname(_context));
		params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_IMAGE);
		mTencent.shareToQQ((Activity)_context, params, qqShareListener);
	}

	public void shareWebpageToQQ(JSONObject paramsJson)	{
		shareType = "2";
		final Bundle params = new Bundle();

		String localImagePath = Tools.getJsonString(paramsJson, "localPath");
		File file = new File(localImagePath);
		if (!file.exists()) {
			Toast.makeText((Activity)_context, "image not exists path=" + localImagePath, Toast.LENGTH_LONG).show();
			_shareHandler = -1;
			return;
		}
		String newPath = SDCARD_ROOT + "/share2.jpg";
		if (!Tools.copyFile(localImagePath, newPath)) {
			_shareHandler = -1;
			return ;
		}

		params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
		params.putString(QQShare.SHARE_TO_QQ_TITLE, PackageUtil.getAppname(_context));
		params.putString(QQShare.SHARE_TO_QQ_SUMMARY, Tools.getJsonString(paramsJson, "description"));
		params.putString(QQShare.SHARE_TO_QQ_TARGET_URL, Tools.getJsonString(paramsJson, "targetUrl"));
		params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL, newPath);
		params.putString(QQShare.SHARE_TO_QQ_APP_NAME, PackageUtil.getAppname(_context));

		mTencent.shareToQQ((Activity)_context, params, qqShareListener);
	}

	public void shareToQQ(String paramsJson, final int cb) {
		_shareHandler = cb;
		JSONObject newsJson;
		try {
			newsJson = new JSONObject(paramsJson);
			int share = Tools.getJsonInt(newsJson, "share");
			if (share == 1) { // 只分享图片
				this.shareLocalImageToQQ(newsJson);
			} else if (share == 2) { // 图文链接
				this.shareWebpageToQQ(newsJson);
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (null != mTencent)
			mTencent.onActivityResult(requestCode, resultCode, data);
	}

	private class BaseUiListener implements IUiListener {
		@Override
		public void onComplete(Object response) {
			if (null == response) {
				return;
			}
			JSONObject jsonResponse = (JSONObject) response;
			if (null != jsonResponse && jsonResponse.length() == 0) {
				return;
			}
			doComplete((JSONObject) response);
		}

		protected void doComplete(JSONObject values) {
		}

		@Override
		public void onError(UiError e) {
		}

		@Override
		public void onCancel() {
		}
	}
}

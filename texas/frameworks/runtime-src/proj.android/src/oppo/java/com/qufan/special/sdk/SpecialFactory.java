package com.qufan.special.sdk;

import android.content.Intent;
import android.view.KeyEvent;
import android.content.Context;

import com.qufan.texas.util.Util;

import com.qufan.texas.nearme.gamecenter.OppoInstance;
import com.qufan.special.sdk.SpecialFactoryModel;
import com.qufan.texas.util.PackageUtil;
import com.alibaba.sdk.android.feedback.impl.FeedbackAPI;

public class SpecialFactory extends SpecialFactoryModel {
	private static SpecialFactory specialInstance = null;
    public static SpecialFactory getInstance(){
        if (specialInstance == null){
            specialInstance = scyCreateInstance();
        }
        return specialInstance;
    }
    private static synchronized SpecialFactory scyCreateInstance(){
        if (specialInstance == null){
            specialInstance =  new SpecialFactory();
        }
        return specialInstance;
    }

	public static boolean isSpecial() {
		return true;
	}

	public static void initWithApplication(final Context context) {

	}

	public static void initWithActivity(final Context context) {
		OppoInstance.getInstance().initSdk(context);
	}

	public static boolean login(int loginType, int loginCb, int gameOverCb) {
		OppoInstance.getInstance().login(loginType, loginCb, gameOverCb);
		return true;
	}

	public static int checkLogin() {
		return OppoInstance.getInstance().checkLogin();
	}

	public static void doSdkGetUserInfoByCP(String playerInfoJson) {
		OppoInstance.getInstance().doSdkGetUserInfoByCP(playerInfoJson);
	}

	//退出时调用
	public static boolean onQuit(final String title, final String sure,
			final String cancel, final int luaCB) {
		OppoInstance.getInstance().doSdkQuit();
		return true;
	}

	public static void onResume() {
		OppoInstance.getInstance().onResume();
	}

	public static void onPause() {
		OppoInstance.getInstance().onPause();
	}

	public static boolean share(String paramsJson, int type, int cb) {
		// if (type == 1) {
		// 	QQInterface.getInstance(Util.context).shareToQQ(paramsJson, cb);
		// } else if (type == 3) {
		// 	WeiXinInterface.getInstance(Util.context).shareToWX(paramsJson, cb);
		// }
		return true;
	}

	// Activity消息监听
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {

	}
}

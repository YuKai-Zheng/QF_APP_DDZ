package com.qufan.special.sdk;

import android.os.Bundle;
import android.content.res.Configuration;
import android.content.Intent;
import android.view.KeyEvent;
import android.app.Activity;
import android.content.Context;
import android.util.Log;

public abstract class SpecialFactoryModel {
	public static SpecialInterf produceSpecial(int specialType){
		return null;
	}

	public static boolean isSpecial() { return false; }

	public static void init(final Activity activity,final Context context,Object...parameters) {}
	
	public static void initWithActivity(final Context context){}
	public static void initWithApplication(final Context context){}

	//activity消息监听
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
	}

	//activity生命周期监听
	public static void onStart() {}
   	public static void onRestart() {}
	public static void onResume() {}
	public static void onPause() {}
	public static void onStop() {}
	public static void onDestroy() {}
	public static void onNewIntent(Intent intent) {}
	public static void onBackPressed() {}
	public static void onConfigurationChanged(Configuration newConfig) {}
	public static void onRestoreInstanceState(Bundle savedInstanceState) {}
	public static void onSaveInstanceState(Bundle outState) {}

	public static boolean onKeyDown(int keyCode, KeyEvent event) {
		boolean ret = false;
	    switch (keyCode) {
		    case KeyEvent.KEYCODE_BACK:
		        break;
		    default:
		        break;
	    }
	    return ret;
	}

	public static boolean login(int loginType, int loginCb, int gameOverCb) {return false;}
	public static boolean share(String paramsJson, int type, int cb) {return false;}
	public static int checkLogin() {
		return 0;
	}
	public static void logoutWithCb(int logoutCb) {}
	public static void logout() {}
	public static boolean accountSwitch(int loginType, int loginCb, int gameOverCb) {return false;}

	//退出时调用
	public static boolean onQuit(final String title, final String sure,
			final String cancel, final int luaCB) {
		return false;
	}

	//角色信息采集接口
	public static void doSdkGetUserInfoByCP(String playerInfoJson) {}

    
}

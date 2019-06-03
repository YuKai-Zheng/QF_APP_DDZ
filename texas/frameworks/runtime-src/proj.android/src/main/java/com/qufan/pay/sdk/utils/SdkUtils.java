package com.qufan.pay.sdk.utils;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.telephony.TelephonyManager;

public class SdkUtils {
	public static boolean containsAny(String str, String searchChars) {
		return str.contains(searchChars);
	}
	public static int getJsonInt(JSONObject json, String key) {
		int result = 0;
		try {
			result = json.getInt(key);
		} catch (JSONException e) {
		}
		return result;
	}
	public static String getJsonString(JSONObject json, String key) {
		String result = null;
		try {
			result = json.getString(key);
		} catch (JSONException e) {
		}
		return result;
	}
	public static void putJsonValue(JSONObject json, String key, Object value) {
		try {
			json.put(key, value);
		} catch (JSONException e) {
		}
	}
	
	 public static int getIMSI(Context context)
	   {
	     int imsi = 0;
	     TelephonyManager telmanager = (TelephonyManager)context.getSystemService("phone");
	     String simOp = telmanager.getSimOperator();
	     if (simOp != null)
	     {
	       if ((simOp.indexOf("46000") >= 0) || (simOp.indexOf("46002") >= 0) || (simOp.indexOf("46007") >= 0))
	         imsi = 1;//移动
	       else if (simOp.equals("46001"))
	         imsi = 2;//联通
	       else if (simOp.equals("46003"))
	         imsi = 3;//电信
	     }
	     return imsi;
	   }
	 
	
}

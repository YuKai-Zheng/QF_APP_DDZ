package com.qufan.pay;

import org.json.JSONException;
import org.json.JSONObject;
import android.content.Context;

import org.cocos2dx.lua.AppActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import com.qufan.pay.unity_pay.BillParams;
import com.qufan.pay.unity_pay.UnitySDKPay;
import com.qufan.pay.unity_pay.ResultListener;

import com.qufan.pay.sdk.wxpay.UnityWXPay;
import com.qufan.pay.sdk.ipaynow.UnityIPayNowExport;

import com.qufan.pay.unity_pay.Constants;
import com.qufan.pay.sdk.utils.AlipayKeys;
import com.qufan.util.XLog;
import com.qufan.config.Common;

import com.qufan.pay.sdk.TexasConstant;

public class UnitySDKFactory {
	private static UnitySDKFactory unityInstance = null;

	UnityWXPay unityWXPay = null;
	UnityIPayNowExport unityIPayNow = null;

	public static UnitySDKFactory getInstance(){
		if (unityInstance == null){
			unityInstance = scyCreateInstance();
		}
		return unityInstance;
	}
	private static synchronized UnitySDKFactory scyCreateInstance(){
		if (unityInstance == null){
			unityInstance =  new UnitySDKFactory();
			unityInstance.init();
		}
		return unityInstance;
	}

	public void init() {
		unityWXPay = new UnityWXPay(
            Constants.HTTP_HOST,
            "bull",
            Common.UNITY_PAY_SECRET,
			UnityWXPay.WXPAY_APP_ID,
			UnityWXPay.WXPAY_PARTNER_ID
        );
        unityWXPay.getUnityPay().setScheme(Constants.SCHEME);

        unityIPayNow = new UnityIPayNowExport(
            Constants.HTTP_HOST,
            "bull",
            Common.UNITY_PAY_SECRET,
            UnityIPayNowExport.IPAYNOW_APP_ID
        );
        unityIPayNow.getUnityPay().setScheme(Constants.SCHEME);
	}

	private void onResultCallLuaCb(int result, final int luaCb) {
		final JSONObject retJson = new JSONObject();
		try {
			retJson.put("resultCode", result);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
            @Override
            public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaCb, retJson.toString());
         	}
        });
	}

	// 微信支付
	private void startWXpay(AppActivity context, BillParams billParams, String payHost, String source, final int luaCb) {
		unityWXPay.getUnityPay().setHost(payHost);
		unityWXPay.getUnityPay().setSource(source);
		unityWXPay.pay(context, billParams, new ResultListener() {
			@Override
			public void onResult(int result, int billID) {
				onResultCallLuaCb(result, luaCb);
			}
		});
	}

	// 现在支付
	private void startIPaynow(AppActivity context, BillParams billParams, String payHost, String source, final int luaCb) {
		unityIPayNow.getUnityPay().setHost(payHost);
		unityIPayNow.getUnityPay().setSource(source);
		unityIPayNow.pay(context, billParams, new ResultListener() {
			@Override
			public void onResult(int result, int billID) {
				onResultCallLuaCb(result, luaCb);
			}
		});
	}

	public void startPay(AppActivity context, BillParams billParams, String payHost, String source, int luaCb) {
		int billType = billParams.billType;
		switch(billType) {
			case TexasConstant.BILL_TYPE_PAYNOW_UNION_PAY:
				billParams.extra.put("pay_channel_type", UnityIPayNowExport.PAY_CHANNEL_TYPE_BANK);
				startIPaynow(context, billParams, payHost, source, luaCb);
				break;
			case TexasConstant.BILL_TYPE_PAYNOW_WEIXIN:
				billParams.extra.put("pay_channel_type", UnityIPayNowExport.PAY_CHANNEL_TYPE_WECHAT);
				startIPaynow(context, billParams, payHost, source, luaCb);
				break;
			case TexasConstant.BILL_TYPE_PAYNOW_ALIPAY:
				billParams.extra.put("pay_channel_type", UnityIPayNowExport.PAY_CHANNEL_TYPE_ALIPAY);
				startIPaynow(context, billParams, payHost, source, luaCb);
				break;
			case TexasConstant.BILL_TYPE_WXPAY:
				billParams.extra.put("pay_channel_type", TexasConstant.BILL_TYPE_WXPAY+"");
				startWXpay(context, billParams, payHost, source, luaCb);
				break;
			default:
				break;
		}
	}
}

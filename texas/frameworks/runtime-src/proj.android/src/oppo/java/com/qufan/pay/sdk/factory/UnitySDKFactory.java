package com.qufan.pay;

import org.json.JSONException;
import org.json.JSONObject;
import android.content.Context;
import android.util.Log;

import org.cocos2dx.lua.AppActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import com.qufan.pay.unity_pay.BillParams;
import com.qufan.pay.unity_pay.UnitySDKPay;
import com.qufan.pay.unity_pay.ResultListener;

import com.qufan.pay.unity_pay.Constants;
import com.qufan.pay.sdk.utils.AlipayKeys;
import com.qufan.util.XLog;
import com.qufan.config.Common;

import com.qufan.texas.nearme.gamecenter.UnityOppo;

import com.qufan.pay.sdk.TexasConstant;

public class UnitySDKFactory {
	private static UnitySDKFactory unityInstance = null;

	UnityOppo unityOppo = null;

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
		unityOppo = new UnityOppo(
            Constants.HTTP_HOST,
            "bull",
            Common.UNITY_PAY_SECRET
        );
        unityOppo.getUnityPay().setScheme(Constants.SCHEME);
	}

	private void onResultCallLuaCb(int result, final int luaCb) {
		Log.e("Oppo支付", "支付结果:"+result);
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

	//Oppo支付
	private void startOppoPay(AppActivity context, BillParams billParams, String payHost, String source, final int luaCb) {
		unityOppo.getUnityPay().setHost(payHost);
		unityOppo.getUnityPay().setSource(source);
		unityOppo.pay(context, billParams, new ResultListener() {
			@Override
			public void onResult(int result, int billID) {
				onResultCallLuaCb(result, luaCb);
			}
		});
	}

	public void startPay(AppActivity context, BillParams billParams, String payHost, String source, int luaCb) {
		int billType = billParams.billType;
		billParams.billType = TexasConstant.BILL_TYPE_OPPO;
		switch(billType) {
			case TexasConstant.BILL_TYPE_OPPO:
				billParams.extra.put("pay_type", "0");
				startOppoPay(context, billParams, payHost, source, luaCb);
				break;
			case TexasConstant.BILL_TYPE_OPPO_ZHIFUBAO:	//弃用
				billParams.extra.put("pay_type", "1");
				startOppoPay(context, billParams, payHost, source, luaCb);
				break;
			case TexasConstant.BILL_TYPE_OPPO_WEIXIN: //弃用
				billParams.extra.put("pay_type", "2");
				startOppoPay(context, billParams, payHost, source, luaCb);
				break;
			default:
				break;
		}
	}
}

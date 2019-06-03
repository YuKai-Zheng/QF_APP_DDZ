package com.hyz.wyddz.wxapi;

import com.qufan.pay.sdk.wxpay.UnityWXPay;

import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{
	private static final String TAG = "WXPayEntryActivity";

    private IWXAPI api;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.pay_result);

    	api = WXAPIFactory.createWXAPI(this, UnityWXPay.WXPAY_APP_ID, false);
        api.handleIntent(getIntent(), this);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
        Log.e(TAG, "onPayReq, errCode = " + req);        
	}

	@Override
	public void onResp(BaseResp resp) {
        Log.e(TAG, "onPayFinish, errCode = " + resp.errCode);
        
        String strPayResult = "";
        switch (resp.errCode) {
            case 0:
                // Intent in = new Intent();
                // in.setClass(WXPayEntryActivity.this, PayFinishedActivity.class);
                // startActivity(in);
                // finish();
                Log.e(TAG, "onResp: 0");                
                break;
            case -1:
                Log.e(TAG, "onResp: -1");

                break;
            case -2:
                Log.e(TAG, "onResp: -2");
                break;
        }
        finish();
	}
}
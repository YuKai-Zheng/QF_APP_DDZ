package com.qufan.pay.sdk.wxpay;

/*

注意:

BillParams.extra 额外增加字段:
    item_name: 商品名称
    pay_channel_type: 支付种类(银行/支付宝/微信)，分别使用 PAY_CHANNEL_TYPE_BANK/PAY_CHANNEL_TYPE_ALIPAY/PAY_CHANNEL_TYPE_WECHAT
 */


import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import com.qufan.pay.unity_pay.BillParams;
import com.qufan.pay.unity_pay.ResultListener;
import com.qufan.pay.unity_pay.UnityPay;
import com.qufan.pay.unity_pay.UnitySDKPay;
import com.qufan.pay.unity_pay.XLog;
import com.qufan.pay.unity_pay.Constants;
import com.qufan.pay.unity_pay.AsyncHttpParams;
import com.qufan.pay.unity_pay.AsyncHttpTask;
import com.qufan.pay.unity_pay.AsyncHttpListener;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.qufan.texas.util.PackageUtil;

import org.json.JSONObject;


import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.cocos2dx.lua.AppActivity;
import com.qufan.pay.sdk.PayWebActivity;

/**
 * 微信官方支付
 */
public class UnityWXPay extends UnitySDKPay {

    private final static double RESULT_TIMEOUT = 5 * 60;

    private static final String PAY_PATH = "/weixin/pay/create"; // 发起支付的url path

    public static final String WXPAY_APP_ID = "wx4c39cf69dd12eddd"; // appID
    public static final String WXPAY_PARTNER_ID = "1522414301"; // partnerID

    private IWXAPI api;
    private static IWXAPI iwxapi;

    private String WXAppID;
    private String PartnerID;

    UnityPay unityPay;

    double resultTimeout = RESULT_TIMEOUT;

    public UnityWXPay(
            String host, String source, String secret,
            String WXAppID, String PartnerID) {
        // 用来做签名使用
        this.unityPay = new UnityPay(host, source, secret);
        this.WXAppID = WXAppID;
        this.PartnerID = PartnerID;
    }

    // 可以返回来设置超时之类的
    public UnityPay getUnityPay() {
        return unityPay;
    }

    @Override
    public void pay(Activity activity, BillParams billParams, ResultListener listener) {
        // 这里传的变量，一个都不能存起来，否则重复调用就出问题了
        this._allocBill(activity, billParams, listener);
    }

    public void setResultTimeout(double resultTimeout) {
        this.resultTimeout = resultTimeout;
    }

    public double getResultTimeout() {
        return this.resultTimeout;
    }

    public static IWXAPI getWXAPI(final Activity activity, final String WXAppID){
        if (iwxapi == null){
            //通过WXAPIFactory创建IWAPI实例
            iwxapi = WXAPIFactory.createWXAPI(activity, WXAppID, false);
            //将应用的appid注册到微信
            iwxapi.registerApp(WXAppID);
        }
        return iwxapi;
    }

    private void _allocBill(final Activity activity, final BillParams billParams, final ResultListener listener) {
        unityPay.allocBill(billParams, new UnityPay.AllocBillListener() {
            @Override
            public void onSucc(final int billID) {
                XLog.e("billID:"+billID);
                _getWXBillInfo(billID, activity, billParams, listener);
            }

            @Override
            public void onFail(int result) {
                if (listener != null) {
                    listener.onResult(result, 0);
                }
            }
        });
    }

    private void _callSDK(final int billID, final Activity activity, final BillParams billParams, final ResultListener listener, JSONObject jsonRsp) {
        // 调用sdk
        try {
            PayReq req = new PayReq();
            req.appId = this.WXAppID;
            req.partnerId = this.PartnerID;
            req.prepayId = jsonRsp.getString("prepayid");
            req.nonceStr = jsonRsp.getString("nonce_str");
            req.timeStamp = jsonRsp.getString("timestamp");
            req.packageValue = "Sign=WXPay";
            req.sign = jsonRsp.getString("sign");

            // 调用微信支付sdk支付方法
            api = getWXAPI(activity, this.WXAppID);
            api.sendReq(req);

            // 等待结果
            _getBillResult(billID, listener);
        }
        catch (Exception e) {
            if (listener != null) {
                listener.onResult(Constants.PAY_RESULT_FAIL, billID);
            }
        }
    }

    private void _getWXBillInfo(final int billID, final Activity activity, final BillParams billParams, final ResultListener listener) {
        AsyncHttpParams httpParams = new AsyncHttpParams();
        httpParams.url = unityPay.genUrl(PAY_PATH);
        httpParams.method = AsyncHttpParams.METHOD_POST;
        httpParams.timeout = RESULT_TIMEOUT;

        JSONObject jsonData = new JSONObject();

        try {
            jsonData.put("OrderNo", billID);
        }
        catch (Exception e) {
            XLog.e("e: " + e);
            return;
        }

        httpParams.params.put("data", jsonData.toString());

        AsyncHttpTask task = new AsyncHttpTask(new AsyncHttpListener() {
            @Override
            public void onSucc(JSONObject jsonRsp) {
                try{
                    XLog.e("微信订单信息");
                    XLog.e(jsonRsp.toString());
                    _callSDK(billID, activity, billParams, listener, jsonRsp);
                }
                catch (Exception e) {
                    XLog.e("e: " + e);
                }
            }

            @Override
            public void onFail(int result) {
                XLog.e("result:"+result);
            }

        });

        task.start(httpParams);
    }

    private void _getBillResult(final int billID, final ResultListener listener) {
        unityPay.getBillResult(billID, this.resultTimeout, new UnityPay.BillResultListener() {
            @Override
            public void onSucc() {
                if (listener != null) {
                    listener.onResult(0, billID);
                }
            }

            @Override
            public void onFail(int result) {
                if (listener != null) {
                    listener.onResult(result, billID);
                }
            }
        });
    }
}

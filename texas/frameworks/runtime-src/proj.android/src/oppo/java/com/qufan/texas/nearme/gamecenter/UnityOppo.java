package com.qufan.texas.nearme.gamecenter;
/*注意:
BillParams.extra 额外增加字段:
    item_name: 商品名称
    pay_channel_type: 支付种类(银行/支付宝/微信)，分别使用 PAY_CHANNEL_TYPE_BANK/PAY_CHANNEL_TYPE_ALIPAY/PAY_CHANNEL_TYPE_WECHAT
 */
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import com.qufan.pay.unity_pay.BillParams;
import com.qufan.pay.unity_pay.ResultListener;
import com.qufan.pay.unity_pay.UnityPay;
import com.qufan.pay.unity_pay.UnitySDKPay;
import com.qufan.pay.unity_pay.XLog;
import com.qufan.pay.unity_pay.Constants;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.util.HashMap;
import java.util.Arrays;
import java.security.MessageDigest;
import java.util.Map;

import org.cocos2dx.lua.AppActivity;
import com.qufan.pay.sdk.PayWebActivity;

import com.nearme.game.sdk.GameCenterSDK;
import com.nearme.game.sdk.callback.ApiCallback;
import com.nearme.game.sdk.common.model.biz.PayInfo;
import com.nearme.platform.opensdk.pay.PayResponse;

/**
 * Created by dantezhu on 16/4/15.
 */
public class UnityOppo extends UnitySDKPay {
    public static final String LOG_TAG = "UnityOppo";
    private final static double RESULT_TIMEOUT = 5 * 60;
    private final static String mPayBackUrl = "/oppo/oppo_order_call";

    UnityPay unityPay;
    double resultTimeout = RESULT_TIMEOUT;

    public UnityOppo(String host, String source, String secret) {
        // 用来做签名使用
        this.unityPay = new UnityPay(host, source, secret);
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

    private void _allocBill(final Activity activity, final BillParams billParams, final ResultListener listener) {
        unityPay.allocBill(billParams, new UnityPay.AllocBillListener() {
            @Override
            public void onSucc(int billID) {
                _callSDK(billID, activity, billParams, listener);
            }

            @Override
            public void onFail(int result) {
                if (listener != null) {
                    listener.onResult(result, 0);
                }
            }
        });
    }

    private void _callSDK(final int billID, final Activity activity, final BillParams billParams, final ResultListener listener) {
        int price           = (int)billParams.amt; // 游戏道具价格
        String productName  = billParams.extra.get("item_name"); // 道具名称
        String billId       = billID+""; // 订单号(此处的billID即是参数中的orderID)
        Integer billtype    = billParams.billType;

        //参数为:订单号(string),自定义字段(string),支付金额(int单位为分),
        PayInfo payInfo = new PayInfo(billId, "自定义字段", price*100); //Integer.parseInt(price)*100
        // PayInfo payInfo = new PayInfo(billId, "自定义字段", 1); //Integer.parseInt(price)*100
        JSONObject ext = new JSONObject();
        try{
            ext.put("uin", billParams.userid);
        } catch (Exception e) {
			e.printStackTrace();
		}

        payInfo.setProductDesc(productName);
        payInfo.setProductName(productName);
        payInfo.setAttach(ext.toString());
        payInfo.setCallbackUrl(unityPay.genUrl(mPayBackUrl));

        XLog.e(ext.toString());

        String payType = billParams.extra.get("pay_type");
        if (payType.equals("1")) {
            payInfo.setType(PayInfo.TYPE_AUTO_ORDER_ALIPAY);
        }
        else if (payType.equals("2")) {
            payInfo.setType(PayInfo.TYPE_AUTO_ORDER_WXPAY);
        }

        GameCenterSDK.getInstance().doPay(activity, payInfo, new ApiCallback() {
            @Override
            public void onSuccess(String resultMsg) {
                _getBillResult(billID, listener);
            }
            @Override
            public void onFailure(String resultMsg, int resultCode) {
                if (PayResponse.CODE_CANCEL != resultCode) {
                    if (listener != null) {
                        listener.onResult(Constants.PAY_RESULT_FAIL, billID);
                    }
                } else {
                    if (listener != null) {
                        listener.onResult(Constants.PAY_RESULT_USER_CANCEL, billID);
                    }
                }
            }
        });
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

    public static String _getDate() {
        Date date = new Date();
        SimpleDateFormat dateformat = new SimpleDateFormat("yyyyMMddHHmmss");
        return dateformat.format(date);
    }
}

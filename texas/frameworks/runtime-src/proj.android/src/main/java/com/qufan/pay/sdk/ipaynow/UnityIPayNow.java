package com.qufan.pay.sdk.ipaynow;

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
import org.json.JSONObject;

import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by dantezhu on 16/4/15.
 */
public class UnityIPayNow extends UnitySDKPay {

    private final static double RESULT_TIMEOUT = 5 * 60;

    // 银行
    public static final String PAY_CHANNEL_TYPE_BANK = "11";
    // 支付宝
    public static final String PAY_CHANNEL_TYPE_ALIPAY = "12";
    // 微信
    public static final String PAY_CHANNEL_TYPE_WECHAT = "13";


    private static final String PAY_PATH = "/BULL/redirect";            // 发起支付的url path
    private static final String NOTIFY_PATH = "/BULL/pay/cb";           // 商户后台通知path
    private static final String FRONT_NOTIFY_PATH = "/BULL/success";    // 商户前台通知path

    private static final String FUNCODE = "WP001";//功能码

    private static final String MHT_ORDER_TYPE = "01";//商户交易类型   01普通消费
    private static final String MHT_CURRENCY_TYPE = "156";//商户订单币种   156人民币
    private static final String MHT_CHARSET = "UTF-8";//商户字符编码
    private static final String DEVICE_TYPE = "06";//设备类型
    private static final String MHT_SIGN_TYPE = "MD5";//商户签名方法


    UnityPay unityPay;

    double resultTimeout = RESULT_TIMEOUT;

    String iPayNowAppID;


    public UnityIPayNow(
            String host, String source, String secret,
            String iPayNowAppID) {
        // 用来做签名使用
        this.unityPay = new UnityPay(host, source, secret);
        this.iPayNowAppID = iPayNowAppID;
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
        // 调用sdk
        try {

            String itemName = billParams.extra.get("item_name");
            String payChannelType = billParams.extra.get("pay_channel_type");

            //装载数据到JSONObject
            JSONObject jsonObject = new JSONObject();

            jsonObject.put("appId", this.iPayNowAppID);
            jsonObject.put("mhtOrderNo", billID);
            jsonObject.put("mhtOrderName", itemName);
            jsonObject.put("mhtOrderType", MHT_ORDER_TYPE);
            jsonObject.put("mhtCurrencyType", MHT_CURRENCY_TYPE);
            // 转成分
            jsonObject.put("mhtOrderAmt", (int)(billParams.amt * 100));
            // jsonObject.put("mhtOrderAmt", 1);       // 将支付金额调成1分钱
            jsonObject.put("mhtOrderDetail", itemName);
            jsonObject.put("mhtOrderStartTime", _getDate());
            // 后台通知使用http
            // jsonObject.put("notifyUrl", this.unityPay.genHttpUrl(NOTIFY_PATH));
            jsonObject.put("notifyUrl", this.unityPay.genUrl2(NOTIFY_PATH));
            jsonObject.put("frontNotifyUrl", this.unityPay.genUrl2(FRONT_NOTIFY_PATH));
            jsonObject.put("mhtCharset", MHT_CHARSET);
            jsonObject.put("payChannelType", payChannelType);
            jsonObject.put("funcode", FUNCODE);
            jsonObject.put("deviceType", DEVICE_TYPE);
            jsonObject.put("mhtSignType", MHT_SIGN_TYPE);

            String data = jsonObject.toString();
            String sign = UnityPay.genMD5(this.unityPay.getSecret() + "|" + PAY_PATH + "|" + data);

            String url = this.unityPay.genUrl2(PAY_PATH) + "?data=" + URLEncoder.encode(data, "UTF-8") + "&sign=" + sign;
            XLog.e("jsonObject: " + jsonObject);
            XLog.e("pay_url: " + url);
            openUrl(activity, url, payChannelType);

            // 等待结果
            _getBillResult(billID, listener);
        }
        catch (Exception e) {
            XLog.e("e: " + e);
            if (listener != null) {
                listener.onResult(Constants.PAY_RESULT_FAIL, billID);
            }
        }
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

    // 打开浏览器
    protected void openUrl(Activity activity, String url, String payChannelType) {
        // 为了实现简单，这里直接使用系统浏览器打开
        // 可以继承后重写

        Intent intent = new Intent();
        intent.setAction("android.intent.action.VIEW");
        Uri content_url = Uri.parse(url);
        intent.setData(content_url);
        activity.startActivity(intent);
    }

    public static String _getDate() {
        Date date = new Date();
        SimpleDateFormat dateformat = new SimpleDateFormat("yyyyMMddHHmmss");
        return dateformat.format(date);
    }
}

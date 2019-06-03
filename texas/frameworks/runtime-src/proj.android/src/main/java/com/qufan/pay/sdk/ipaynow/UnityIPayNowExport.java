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
import org.json.JSONObject;

import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.cocos2dx.lua.AppActivity;
import com.qufan.pay.sdk.PayWebActivity;
import com.qufan.pay.sdk.ipaynow.UnityIPayNow;
import com.qufan.pay.sdk.ipaynow.UnityIPayNowExport;

/**
 * Created by dantezhu on 16/4/15.
 */
public class UnityIPayNowExport extends UnityIPayNow {
    public static final String IPAYNOW_APP_ID = "1493177014104656"; //商户应用唯一标识

    public UnityIPayNowExport(
            String host, String source, String secret,
            String iPayNowAppID) {
        super(host, source, secret, iPayNowAppID);
    }
}

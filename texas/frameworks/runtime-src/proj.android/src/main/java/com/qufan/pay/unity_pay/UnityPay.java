package com.qufan.pay.unity_pay;

import org.json.JSONObject;
import java.security.MessageDigest;
import android.util.Log;
import com.qufan.pay.unity_pay.Constants;

public class UnityPay {

    private String source;
    private String secret;
    private String host;
    private String scheme = Constants.SCHEME_HTTP;

    // 超时时间(秒)。<=0: 不设置超时
    private double timeout = Constants.HTTP_TIMEOUT;

    public UnityPay(String host, String source, String secret) {
        this.host = host;
        this.source = source;
        this.secret = secret;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public String getHost() {
        return host;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getSource() {
        return source;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public String getSecret() {
        return secret;
    }

    public void setScheme(String scheme) {
        this.scheme = scheme;
    }

    public String getScheme() {
        return scheme;
    }

    public void setTimeout(double timeout) {
        this.timeout = timeout;
    }

    public double getTimeout() {
        return timeout;
    }

    public void allocBill(BillParams billParams, final AllocBillListener listener) {

        final String urlPath = Constants.URL_PATH_ALLOC_BILL;

        AsyncHttpParams httpParams = new AsyncHttpParams();
        httpParams.url = genUrl(urlPath);
        httpParams.method = AsyncHttpParams.METHOD_POST;
        httpParams.timeout = this.timeout;

        JSONObject jsonBill = billParams.toJSON();
        try {
            jsonBill.put("source", this.source);
            jsonBill.put("os", Constants.OS);
            jsonBill.put("sdk_version", Constants.VERSION);
        }
        catch (Exception e) {
            XLog.e("e: " + e);
            listener.onFail(Constants.RESULT_EXCEPTION);
            return;
        }

        final String strJsonData = jsonBill.toString();
        String sign = genMD5(this.secret + "|" + urlPath + "|" + strJsonData);
        httpParams.params.put("data", strJsonData);
        httpParams.params.put("sign", sign);

        AsyncHttpTask task = new AsyncHttpTask(new AsyncHttpListener() {
            @Override
            public void onSucc(JSONObject jsonRsp) {
                try{
                    int rspResult = jsonRsp.getInt("ret") ;
                    if (rspResult != 0) {
                        listener.onFail(rspResult);
                    }
                    else {
                        // 要先验证签名
                        int billID = jsonRsp.getInt("bill_id");
                        String sign = jsonRsp.getString("sign");

                        String calcSign = genMD5(
                                secret + "|" + urlPath + "|" + strJsonData + "|" + billID
                        );

                        if (!sign.equals(calcSign)) {
                            XLog.e("sign not match. rsp_sign: " + sign + ", calc_sign: " + calcSign);
                            listener.onFail(Constants.RESULT_SIGN_INVALID);
                        }
                        else {
                            // 总算成功
                            listener.onSucc(billID);
                        }
                    }
                }
                catch (Exception e) {
                    XLog.e("e: " + e);
                    listener.onFail(Constants.RESULT_EXCEPTION);
                }
            }

            @Override
            public void onFail(int result) {
                listener.onFail(result);
            }

        });

        task.start(httpParams);
    }

    public void getBillResult(final int billID, final double totalTimeout, final BillResultListener listener) {

        final long nowTimeMS = System.currentTimeMillis();
        final String urlPath = Constants.URL_PATH_BILL_RESULT;

        AsyncHttpParams httpParams = new AsyncHttpParams();
        httpParams.url = genUrl(urlPath);
        httpParams.method = AsyncHttpParams.METHOD_POST;
        // 直接使用 totalTimeout，防止timeout>totalTimeout的情况有问题
        httpParams.timeout = totalTimeout;
        httpParams.params.put("bill_id", String.valueOf(billID));

        AsyncHttpTask task = new AsyncHttpTask(new AsyncHttpListener() {

            @Override
            public void onSucc(JSONObject jsonRsp) {
                try{
                    int rspResult = jsonRsp.getInt("ret") ;
                    if (rspResult != 0) {
                        listener.onFail(rspResult);
                    }
                    else {
                        // 要先验证签名
                        String sign = jsonRsp.getString("sign");

                        String calcSign = genMD5(
                                secret + "|" + urlPath + "|" + billID
                        );

                        if (!sign.equals(calcSign)) {
                            XLog.e("sign not match. rsp_sign: " + sign + ", calc_sign: " + calcSign);
                            listener.onFail(Constants.RESULT_SIGN_INVALID);
                        }
                        else {
                            // 总算成功
                            listener.onSucc();
                        }
                    }
                }
                catch (Exception e) {
                    XLog.e("e: " + e);
                    listener.onFail(Constants.RESULT_EXCEPTION);
                }
            }

            @Override
            public void onFail(int result) {
                if (result == Constants.RESULT_HTTP_FAIL) {
                    // 如果是网络出现问题，在总超时没有达到之前，那就要一直循环
                    double remainTimeout = totalTimeout - (System.currentTimeMillis() - nowTimeMS) / 1000.0;
                    // 转成int判断是防止误差
                    if ((int)remainTimeout > 0) {
                        getBillResult(billID, remainTimeout, listener);
                    }
                    else {
                        listener.onFail(result);
                    }
                    return;
                }
                listener.onFail(result);
            }
        });

        task.start(httpParams);
    }

    public void setBillResult(final int billID, final int result, final JSONObject data, final BillResultListener listener) {
        // data 为额外数据，比如苹果支付，需要传入一些额外数据用来验证

        final String urlPath = Constants.URL_PATH_APP_PAY_CB;

        AsyncHttpParams httpParams = new AsyncHttpParams();
        httpParams.url = genUrl(urlPath);
        httpParams.method = AsyncHttpParams.METHOD_POST;
        httpParams.timeout = this.timeout;
        httpParams.params.put("bill_id", String.valueOf(billID));
        httpParams.params.put("result", String.valueOf(result));

        String strJsonData = data == null ? "" : data.toString();
        String sign = genMD5(
                secret + "|" + urlPath + "|" + billID + "|" + result + "|" + strJsonData
        );

        httpParams.params.put("data", strJsonData);
        httpParams.params.put("sign", sign);

        AsyncHttpTask task = new AsyncHttpTask(new AsyncHttpListener() {
            @Override
            public void onSucc(JSONObject jsonRsp) {
                try{
                    int rspResult = jsonRsp.getInt("ret") ;
                    if (rspResult != 0) {
                        listener.onFail(rspResult);
                    }
                    else {
                        // 要先验证签名
                        String sign = jsonRsp.getString("sign");

                        String calcSign = genMD5(
                                secret + "|" + urlPath + "|" + billID + "|" + rspResult
                        );

                        if (!sign.equals(calcSign)) {
                            XLog.e("sign not match. rsp_sign: " + sign + ", calc_sign: " + calcSign);
                            listener.onFail(Constants.RESULT_SIGN_INVALID);
                        }
                        else {
                            // 总算成功
                            listener.onSucc();
                        }
                    }
                }
                catch (Exception e) {
                    XLog.e("e: " + e);
                    listener.onFail(Constants.RESULT_EXCEPTION);
                }
            }

            @Override
            public void onFail(int result) {
                listener.onFail(result);
            }
        });

        task.start(httpParams);
    }

    // 生成url，外面也可以调用。
    public String genUrl(String path) {
        return String.format("%s://%s%s", scheme, host, path);
    }

    public String genUrl2(String path) {
        return String.format("%s://%s%s", scheme, Constants.HTTP_HOST, path);
    }

    // 生成http的url
    public String genHttpUrl(String path) {
        return String.format("%s://%s%s", Constants.SCHEME_HTTP, host, path);
    }

    // 生成md5
    public static String genMD5(String val) {
        try{
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            md5.update(val.getBytes());
            byte[] m = md5.digest();//加密
            return hexToString(m);
        }
        catch (Exception e) {
            return null;
        }
    }

    public static String hexToString(byte[] b){
        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < b.length; i ++){
            //sb.append(b[i]);
            sb.append(String.format("%02x", b[i]));
        }
        return sb.toString();
    }


    public static class AllocBillListener {
        public void onSucc(int billID) {
        }

        public void onFail(int result) {
        }
    }

    public static class BillResultListener {
        public void onSucc() {
        }

        public void onFail(int result) {
        }
    }

}

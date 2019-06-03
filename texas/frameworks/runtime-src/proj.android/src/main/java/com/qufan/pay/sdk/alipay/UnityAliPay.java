// package com.qufan.pay.sdk.alipay;

// /*

// 注意:

// BillParams.extra 额外增加字段:
//     item_name: 计费点名字

// 支付宝sdk版本: v2.0.1
// 参考文档: https://doc.open.alipay.com/doc2/detail.htm

// 返回码	含义
// 9000	订单支付成功
// 8000	正在处理中
// 4000	订单支付失败
// 6001	用户中途取消
// 6002	网络连接出错


// 生成公钥和密钥的方法

// 下载移动支付的sdk后，在openssl目录，有生成方法。

// 生成结束后会生成:
// rsa_private_key.pem:  这个文件，去掉开头和结尾后，配置在代码里面作为密钥。不要去掉换行符。
// rsa_public_key.pem: 这个文件，去掉开头和结尾后，配置到alipay的rsa加密的密钥中。要去掉换行符。

// 而服务器端的验证公钥，就是使用的rsa加密右边的<查看支付宝公钥>按钮中的密钥。
// 在python中进行验证的话，要去掉换行，并加上-----BEGIN RSA PRIVATE KEY-----，具体看unity_pay/config.py

//  */


// import android.app.Activity;
// import android.text.TextUtils;
// import com.qufan.pay.unity_pay.BillParams;
// import com.qufan.pay.unity_pay.ResultListener;
// import com.qufan.pay.unity_pay.UnityPay;
// import com.qufan.pay.unity_pay.UnitySDKPay;
// import com.qufan.pay.unity_pay.XLog;
// import com.qufan.pay.unity_pay.Constants;
// import com.alipay.sdk.app.PayTask;
// import com.qufan.pay.sdk.alipay.SignUtils;
// import com.qufan.pay.sdk.alipay.PayResult;
// import com.qufan.pay.sdk.alipay.Base64;

// import java.io.UnsupportedEncodingException;
// import java.net.URLEncoder;

// /**
//  * Created by dantezhu on 16/4/15.
//  */
// public class UnityAliPay extends UnitySDKPay {

//     private final static double RESULT_TIMEOUT = 5 * 60;

//     private final static String NOTIFY_PATH = "/alipay/pay/cb";

//     UnityPay unityPay;

//     double resultTimeout = RESULT_TIMEOUT;

//     String aliPartner;
//     String aliSeller;
//     String aliPrivateKey;

//     public UnityAliPay(
//             String host, String source, String secret,
//             String aliPrivateKey, String aliPartner, String aliSeller) {
//         unityPay = new UnityPay(host, source, secret);
//         this.aliPrivateKey = aliPrivateKey;
//         this.aliPartner = aliPartner;
//         this.aliSeller = aliSeller;
//     }

//     // 可以返回来设置超时之类的
//     public UnityPay getUnityPay() {
//         return unityPay;
//     }

//     @Override
//     public void pay(Activity activity, BillParams billParams, ResultListener listener) {
//         // 这里传的变量，一个都不能存起来，否则重复调用就出问题了
//         this._allocBill(activity, billParams, listener);
//     }

//     public void setResultTimeout(double resultTimeout) {
//         this.resultTimeout = resultTimeout;
//     }

//     public double getResultTimeout() {
//         return this.resultTimeout;
//     }

//     private void _allocBill(final Activity activity, final BillParams billParams, final ResultListener listener) {
//         unityPay.allocBill(billParams, new UnityPay.AllocBillListener() {
//             @Override
//             public void onSucc(int billID) {
//                 _callSDK(billID, activity, billParams, listener);
//             }

//             @Override
//             public void onFail(int result) {
//                 if (listener != null) {
//                     listener.onResult(result, 0);
//                 }
//             }
//         });
//     }

//     private void _callSDK(final int billID, final Activity activity, final BillParams billParams, final ResultListener listener) {
//         // 调用sdk
//         try {
//             // 可能抛异常
//             String orderInfo = _getSDKOrderInfo(billID, billParams);
//             String sign = SignUtils.sign(orderInfo, aliPrivateKey);

//             // 仅需对sign 做URL编码
//             sign = URLEncoder.encode(sign, "UTF-8");

//             final String payInfo = orderInfo + "&sign=\"" + sign + "\"&" + "sign_type=\"RSA\"";

//             new Thread(new Runnable() {
//                 @Override
//                 public void run() {
//                     // 构造PayTask 对象
//                     PayTask alipay = new PayTask(activity);

//                     // 调用支付接口
//                     String strResult = alipay.pay(payInfo);

//                     PayResult payResult = new PayResult(strResult);

//                     String resultInfo = payResult.getResult();// 同步返回需要验证的信息

//                     String resultStatus = payResult.getResultStatus();

//                     // 判断resultStatus 为9000则代表支付成功，具体状态码代表含义可参考接口文档
//                     if (TextUtils.equals(resultStatus, "9000")) {
//                         _getBillResult(billID, listener);
//                     } else {
//                         XLog.e("strResult: " + strResult);

//                         // 判断resultStatus 为非"9000"则代表可能支付失败
//                         // "8000"代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
//                         if (TextUtils.equals(resultStatus, "8000")) {
//                             if (listener != null) {
//                                 listener.onResult(Constants.PAY_RESULT_WAIT_CONFIRM, billID);
//                             }
//                         }
//                         else if (TextUtils.equals(resultStatus, "6001")) {
//                             if (listener != null) {
//                                 listener.onResult(Constants.PAY_RESULT_USER_CANCEL, billID);
//                             }
//                         }
//                         else {
//                             // 其他值就可以判断为支付失败
//                             if (listener != null) {
//                                 listener.onResult(Constants.PAY_RESULT_FAIL, billID);
//                             }
//                         }
//                     }

//                 }
//             }).start();

//         }
//         catch (Exception e) {
//             XLog.e("e: " + e);
//             if (listener != null) {
//                 listener.onResult(Constants.PAY_RESULT_FAIL, billID);
//             }
//         }
//     }

//     private void _getBillResult(final int billID, final ResultListener listener) {
//         unityPay.getBillResult(billID, this.resultTimeout, new UnityPay.BillResultListener() {
//             @Override
//             public void onSucc() {
//                 if (listener != null) {
//                     listener.onResult(0, billID);
//                 }
//             }

//             @Override
//             public void onFail(int result) {
//                 if (listener != null) {
//                     listener.onResult(result, billID);
//                 }
//             }
//         });
//     }

//     private String _getSDKOrderInfo(int billID, BillParams billParams) throws UnsupportedEncodingException{
//         StringBuilder sb = new StringBuilder();
//         sb.append("partner=\"");
//         sb.append(aliPartner);
//         sb.append("\"&out_trade_no=\"");
//         sb.append(billID);
//         sb.append("\"&subject=\"");
//         sb.append(URLEncoder.encode(billParams.extra.get("item_name"), "UTF-8"));
//         sb.append("\"&body=\"");
//         sb.append(URLEncoder.encode(billParams.extra.get("item_name"), "UTF-8"));
//         sb.append("\"&total_fee=\"");
//         // 注意，最多精确到分，否则支付宝会报错
//         sb.append(String.format("%.2f", billParams.amt));
//         sb.append("\"&service=\"mobile.securitypay.pay");
//         sb.append("\"&_input_charset=\"UTF-8");
//         sb.append("\"&return_url=\"");
//         sb.append(URLEncoder.encode("http://m.alipay.com", "UTF-8"));
//         sb.append("\"&notify_url=\"");
//         sb.append(URLEncoder.encode(unityPay.genHttpUrl(NOTIFY_PATH), "UTF-8"));
//         sb.append("\"&payment_type=\"1");
//         sb.append("\"&seller_id=\"");
//         sb.append(aliSeller);
//         sb.append("\"&it_b_pay=\"10m");
//         sb.append("\"");

//         return new String(sb);
//     }
// }

package com.qufan.pay.unity_pay;

/**
 * Created by dantezhu on 16/4/14.
 */
public class Constants {
    // 版本号
    public final static int VERSION = 2017051801;

    public final static String OS = "android";

    public static String SCHEME = "https";       //正式服
    public static String HTTP_HOST = "wxddz.qfun.com";   //正式服
    // public static String SCHEME = "http";//外网测试
	// public static String HTTP_HOST = "wxddz-test.qfun.com";//外网测试
    public final static String URL_PATH_ALLOC_BILL = "/app/bill/alloc_v2";
    public final static String URL_PATH_APP_PAY_CB = "/app/pay/cb";
    public final static String URL_PATH_BILL_RESULT = "/bill/result";

    public final static String SCHEME_HTTP = "http";

    // 超时时间
    public final static double HTTP_TIMEOUT = 30;

    public final static int RESULT_HTTP_PARAMS_INVALID = -100;
    public final static int RESULT_HTTP_FAIL = -101;
    public final static int RESULT_SIGN_INVALID = -103;
    public final static int RESULT_EXCEPTION = -201;


    // SDK层支付结果。在这里统一定义，这样调用方更简单一些。
    // 一定要使用正值，代表sdk层的错误
    // 不知道支付成功还是失败，等待服务器结果吧
    public final static int PAY_RESULT_WAIT_CONFIRM = 10;
    // 用户主动取消支付
    public final static int PAY_RESULT_USER_CANCEL = 11;
    public final static int PAY_RESULT_FAIL = 12;

}

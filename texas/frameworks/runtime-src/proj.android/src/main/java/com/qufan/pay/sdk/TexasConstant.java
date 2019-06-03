package com.qufan.pay.sdk;

import android.app.Activity;

public class TexasConstant {

	/**代表请求activity的id号*/
	public static final int REQUEST_CODE = 9;
	/**
	 * 当前显示的  activity
	 */
	public static Activity activityInstance = null;

	/**
	 * 应用标识
	 */
	public static String SOURCE = "bull";

	/**
	 * SDK版本号，每次升级的时候记得手动升级
	 */
	public static final int  VERSION_CODE = 2015030500;

	// 支付类型
	public static final int BILL_TYPE_PAYNOW_UNION_PAY = 38;    //现在支付银联
	public static final int BILL_TYPE_PAYNOW_ALIPAY = 39;       //现在支付支付宝
	public static final int BILL_TYPE_PAYNOW_WEIXIN = 40;	   //现在支付微信

	public static final int BILL_TYPE_OPPO = 60; //OPPO支付
    public static final int BILL_TYPE_OPPO_ZHIFUBAO = 610; //只是客户端使用：OPPO支付宝支付 已弃用
    public static final int BILL_TYPE_OPPO_WEIXIN = 620; //只是客户端使用：OPPO微信支付 已弃用

	public static final int BILL_TYPE_WXPAY = 601;	   //微信官方支付


	// 支付广播
	// public static final int RQF_PAY_FAIL = 2;
	/**
	 *这个是activity间的传递  ，这个参数暂时没有任何用
	 */
	public static final int RESULT_CODE = 0;

	public static final int PAY_REQUEST_OVER = 110;
	/**
	 * 支付接口返回是成功后  通知自己的服务端 并等待返回结果
	 */
	public static final int PAY_RESULTS_LOADING = 119;
	/**
	 * 关闭支付的activity
	 */
	public static final int CLOSE_PAY_ACTIVITY = 122;

	//生成订单号状态
	public static final int BILL_CREATE_SUC = 126;
	public static final int BILL_CREATE_FIAL = 127;
	public static final int ALL_PAY_FIAL = 128;
	/**
	 * 某些支付失败 转别的支付
	 */
	public static final int FIAL_TO_OTHER_PAY = 129;

	/**
	 * 音乐设置
	 */
	public static int MUSIC_SET = 1;
	/**
	 *  游戏基地
	 */
	public static String GAME_SPOT_USER_ID = "-1";
}

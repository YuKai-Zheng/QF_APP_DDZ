package com.qufan.config;

public class Common {
	/**
	 * 注册时加密 秘钥
	 */
    // 不能用final，每个使用的位置会直接显示出来。不带final只会在定义的部分有显示，似乎也没什么卵用
    // public static String UNITY_PAY_SECRET = "bg+t%je3i0wd=9%@p@=-miicg&1!%4#n";
	public static String UNITY_PAY_SECRET = "EFyhU+#^$gCoR4knZPJ_A26tDwXO)BVd";
	public static final int NOTIFY_QUIT_WEB = 10;
	public static final int NOTIFY_SHOW_WEB = 15;
}

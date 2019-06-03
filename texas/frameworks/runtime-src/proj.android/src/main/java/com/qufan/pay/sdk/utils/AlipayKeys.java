package com.qufan.pay.sdk.utils;

//
// 请参考 Android平台安全支付服务(msp)应用开发接口(4.2 RSA算法签名)部分，并使用压缩包中的openssl RSA密钥生成工具，生成一套RSA公私钥。
// 这里签名时，只需要使用生成的RSA私钥。
// Note: 为安全起见，公私钥的设置须从商户的服务端中获取，不要在客户端中写死。
public final class AlipayKeys {

	// 合作商户ID，用签约支付宝账号登录www.alipay.com后，在商家服务页面中获取。
	public static final String DEFAULT_PARTNER = "2088111307636994";

	// 商户收款的支付宝账号
	public static final String DEFAULT_SELLER = "2029557328@qq.com";

	// 商户（RSA）私钥
	public static final String PRIVATE = "MIICXAIBAAKBgQDElrMjGFYijaf+pOmQ+gBJh9ZDd+s5wYG6ERssJTJBfjD9oLNYxHwyL/uxQR4Nm2+1nakMdMeO4KqjZygCwQ+XWJNiLAHf9uoRf5/mJzY3N8uARh8mdYq9Dba0pd/qr8JNwxSD/DOT3ias+06jIE3b071zAkIcqvBWm3lOdoJYBwIDAQABAoGAG8C6oWW6Iz6kTMqzPohMqhTHJtczGgA7dC0eDOljYuORvvyE1S9H6T3k5m0u9PTQnG8ZgmyqD32gGVliyKDAtnme16MPrX0ThzfV6YWgAjv/iq5Fy5K9Wfr7MiVUv93XUbMUqVN3mdDQ7sBCa3gHqTSO5LWzNUnu9I+WFTg0V6ECQQDqtY3hJyBr2BV8B5cv0Mb7OwwfyqQC2Bd43ivJYfuX+EsxCn+E6mgIS7DuyufNwL9oGRjWD1yd2F5MFmdiKUh7AkEA1mvn8Mfq6JDQbJkLr76mP2SNAJNS87lEgcbLea+0zeDSlIT4Zf6JykTOMeRASmKTgTi8xWFDZS/rEapEpoLm5QJAJqDOwvmPinA7yPfu1/3CYeKr8ieFqrop0sit6CzqHW7N4TpbFmMF0Ce07PgUAnbwiY9n2QMaORg9HMSrKyqkNQJBALIUKix6DKmb483diawq/W12t/g7YtBSFQhnLwRgHhxCVQHOMXKb5JodbNZYx+A/YFwY4AZZkhyOoH8qVxunadUCQGowYeqC+aaQFVqGilGUtBiNWGcezFk6u3MiG3L4Wqd/TV5xXlKDDhRbjYgOtDDVYcqD3etvqMVZKzKAjeR1PxQ=";

	// 支付宝（RSA）公钥
	// public static final String PUBLIC =
	// "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB";

	public static final String PUBLIC = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB";
}

package com.qufan.pay.unity_pay;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by dantezhu on 16/4/14.
 */
public class AsyncHttpParams {

    public final static int METHOD_GET = 1;
    public final static int METHOD_POST = 2;

    public String url;
    public int method = METHOD_GET;
    // 超时时间(秒)。<=0: 不设置超时
    public double timeout = 0;
    public Map<String, String> params = new HashMap<String, String>(); // get 或者 post参数
}

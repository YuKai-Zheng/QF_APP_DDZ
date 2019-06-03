package com.qufan.push;

import android.os.Bundle;
import android.util.Log;

import com.alibaba.sdk.android.push.AndroidPopupActivity;

import java.util.Map;

/**
 * 辅助推送通道指定打开的弹窗activity,目前包括:小米弹窗、华为弹窗
 */
public class ThirdPushPopupActivity extends AndroidPopupActivity {
    final String TAG = "ThirdPushPopupActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    /**
     * 弹窗消息打开互调。辅助弹窗通知被点击时,此回调会被调用,用户可以从该回调中获取相关参数进行下一步处理
     * @param title
     * @param content
     * @param extraMap
     */
    @Override
    protected void onSysNoticeOpened(String title, String content, Map<String, String> extraMap) {
        Log.e(TAG, "Receive ThirdPush notification, title: " + title + ", content: " + content + ", extraMap: " + extraMap);
    }
}
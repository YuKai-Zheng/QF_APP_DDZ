package com.qufan.texasx;

import java.util.Iterator;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Notification;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.os.Handler;
import android.support.v4.app.NotificationCompat;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.qufan.pay.sdk.TexasConstant;
import com.qufan.texas.util.DeviceUtil;
import com.qufan.texas.util.PackageUtil;
import com.qufan.texas.util.RelayoutTool;

import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;
import com.alibaba.sdk.android.push.register.HuaWeiRegister;
import com.alibaba.sdk.android.push.register.MiPushRegister;

import android.util.Log;
import com.qufan.texas.BuildConfig;
import com.qufan.util.XLog;

public class GameApplication extends Application {
	// 如果包名修改了请务必同步这里，否则游戏进程初始化逻辑执行不到！
	private String mProcessName;
	private static Context context;

	@Override
	public void onCreate() {
		super.onCreate();

		if (BuildConfig.DEBUG) {
			XLog.setLevel(Log.DEBUG);
		}
		else {
			XLog.setLevel(Log.ERROR);
		}

		context = this;
		int pid = android.os.Process.myPid();
		mProcessName = getProcessName(pid);
		// 只在游戏进程里执行下列逻辑，百度 Push 进程不用，否则与后台的心跳、登陆包等会发双份。
		if (null != mProcessName && mProcessName.equals(this.getPackageName())) {
			new DeviceUtil(this);
			new RelayoutTool(this, 1920, 1080);
		}

		initCloudChannel(this);
	}

	private String getProcessName(int pID) {
		String processName = "";
		ActivityManager am = (ActivityManager) this
				.getSystemService(ACTIVITY_SERVICE);
		List<ActivityManager.RunningAppProcessInfo> list = am
				.getRunningAppProcesses();
		if (null != list) {
			Iterator<RunningAppProcessInfo> i = list.iterator();
			while (i.hasNext()) {
				ActivityManager.RunningAppProcessInfo info = (ActivityManager.RunningAppProcessInfo) (i
						.next());
				try {
					if (info.pid == pID) {
						processName = info.processName;
					}
				} catch (Exception e) {
					// Log.d("Process", "Error>> :"+ e.toString());
				}
			}
		}
		return processName;
	}
 	/**
     * 初始化云推送通道
     * @param applicationContext
     */
    private void initCloudChannel(Context applicationContext) {
		// 创建notificaiton channel
        this.createNotificationChannel();
        PushServiceFactory.init(applicationContext);
        CloudPushService pushService = PushServiceFactory.getCloudPushService();
        pushService.register(applicationContext, new CommonCallback() {
            @Override
            public void onSuccess(String response) {
                Log.e("aliyun-push", "init cloudchannel success");
				Log.e("aliyun-push", PushServiceFactory.getCloudPushService().getDeviceId() + "");
            }
            @Override
            public void onFailed(String errorCode, String errorMessage) {
                Log.e("aliyun-push", "init cloudchannel failed -- errorcode:" + errorCode + " -- errorMessage:" + errorMessage);
            }
        });

		// 注册方法会自动判断是否支持小米系统推送，如不支持会跳过注册。
		MiPushRegister.register(applicationContext, "2882303761517932353", "5681793291353");
		// 注册方法会自动判断是否支持华为系统推送，如不支持会跳过注册。
		HuaWeiRegister.register(applicationContext);
    }

	private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            // 通知渠道的id
            String id = PackageUtil.getConfigString(context, "UMENG_CHANNEL");
            // 用户可以看到的通知渠道的名字.
            CharSequence name = PackageUtil.getAppname(context);
            // 用户可以看到的通知渠道的描述
            String description = PackageUtil.getAppname(context);
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(id, name, importance);
            // 配置通知渠道的属性
            mChannel.setDescription(description);
            // 设置通知出现时的闪灯（如果 android 设备支持的话）
            mChannel.enableLights(true);
            mChannel.setLightColor(Color.RED);
            // 设置通知出现时的震动（如果 android 设备支持的话）
            mChannel.enableVibration(true);
            mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            //最后在notificationmanager中创建该通知渠道
            mNotificationManager.createNotificationChannel(mChannel);
        }
    }

	@Override
	public void onLowMemory() {
		this.onTerminate();
		super.onLowMemory();
	}
}

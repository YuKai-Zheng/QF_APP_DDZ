package com.qufan.texas.util;

import java.util.List;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.app.ActivityManager.RunningTaskInfo;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Resources;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.CallLog;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.WindowManager;
import com.qufan.util.XLog;

/**
 * @author Junhong.Li 项目名称：ActivityMgr 类名称：PackageUtil (用一句话来描述这个类)
 *         如有疑问请联系：haiyanmain@live.com 修改时间：2014-3-24 下午8:44:24 修改人：Junhong
 */
public class PackageUtil {
	private static final String TAG = "PackageUtil";
	private static final String DEVICE_ID = "Unknow";

	private static final int HONEYCOMB = 11;

	/**
	 * 
	 * @description:获取系统版本号
	 * @return
	 * @return int
	 * @throws
	 */
	public static int getVersionCode(Context context) {
		int verCode = 0;
		try {
			verCode = context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0).versionCode;
		} catch (NameNotFoundException e) {
		}

		return verCode;
	}

	
	/**
	 * 获取应用程序的外部版本号
	 * 
	 * @return 外部版本号
	 * @throws NameNotFoundException
	 *             找不到信息的异常
	 */
	public static String getVersionName(Context context) {
		String versionName = null;
		try {
			versionName = context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0).versionName;
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return versionName;
	}

	public static String getpackageName(Context context){
		return context.getPackageName();
	}

	// 获取App Name
	public static String getAppname(Context context) {
		String appname = null;
		try {
			PackageManager packageManager = context.getPackageManager();
			ApplicationInfo appInfo = packageManager.getApplicationInfo(context.getPackageName(), 0);
			appname = (String)packageManager.getApplicationLabel(appInfo);
		} catch (PackageManager.NameNotFoundException e) {
			appname = "__";
		}
		return appname;
	}
	/**
	 * 获取MAC地址
	 * 
	 * @return 返回MAC地址
	 */
	private static String getLocalMacAddress(Context context) {
		WifiManager wifi = (WifiManager) context
				.getSystemService(Context.WIFI_SERVICE);
		WifiInfo info = wifi.getConnectionInfo();

		return info.getMacAddress()==null?"":info.getMacAddress();
	}

	/**
	 * 获取位置信息
	 * 
	 * @param context
	 * @return
	 * @return String
	 */
	public static String getArea(Context context) {
		return "";
	}

	/**
	 * 获取 string.xml 文件定义的字符串
	 * 
	 * @param resourceId
	 *            资源id
	 * @return 返回 string.xml 文件定义的字符串
	 */
	public static String getString(Context context, int resourceId) {
		Resources res = context.getResources();
		return res.getString(resourceId);
	}

	/**
	 * 
	 * @return 获得手机端终端标识
	 */
	public static String getTerminalSign(Context context) {
		String tvDevice = getLocalMacAddress(context);
		if (tvDevice == null) {
			TelephonyManager tm = (TelephonyManager) context
					.getSystemService(Context.TELEPHONY_SERVICE);
			tvDevice = tm.getDeviceId();
		}

		if (tvDevice == null) {
			tvDevice = DEVICE_ID;
		}

		return tvDevice;
	}

	/**
	 * 
	 * @return 获得手机型号
	 */
	public static String getDeviceType() {
		String deviceType = android.os.Build.MODEL;
		return deviceType;
	}

	/**
	 * 
	 * @return 获得操作系统版本号
	 */

	public static String getSysVersion() {
		String sysVersion = android.os.Build.VERSION.RELEASE;
		return sysVersion;
	}

	public static String getTelNumber(Context context) {
		String telNumber = CallLog.Calls.getLastOutgoingCall(context);
		/*
		 * ContentResolver cResolver =
		 * ThinkDriveApplication.CONTEXT.getContentResolver(); Cursor cursor =
		 * cResolver.query(ContactsContract.Contacts.CONTENT_URI, null, null,
		 * null, null); String string = null; if (cursor != null &&
		 * cursor.getCount() > 0) { cursor.moveToFirst(); while
		 * (cursor.moveToNext()) { //取得联系人名字 int nameFieldColumnIndex =
		 * cursor.getColumnIndex(PhoneLookup.DISPLAY_NAME); String contact =
		 * cursor.getString(nameFieldColumnIndex); //取得电话号码 String ContactId =
		 * cursor
		 * .getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));
		 * Cursor phone =
		 * cResolver.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
		 * null, ContactsContract.CommonDataKinds.Phone.CONTACT_ID + "=" +
		 * ContactId, null, null);
		 * 
		 * while(phone.moveToNext()) { String PhoneNumber =
		 * phone.getString(phone
		 * .getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
		 * string += (contact + ":" + PhoneNumber + "\n"); } }
		 * 
		 * EvtLog.i(TAG, string);
		 * 
		 * }
		 * 
		 * if (cursor != null) { cursor.close(); }
		 */

		return telNumber;
	}

	/**
	 * 读取manifest.xml中application标签下的配置项，如果不存在，则返回空字符串
	 * 
	 * @param key
	 *            键名
	 * @return 返回字符串
	 */
	public static String getConfigString(Context context, String key) {
		String val = "";
		try {
			ApplicationInfo appInfo = context.getPackageManager()
					.getApplicationInfo(context.getPackageName(),
							PackageManager.GET_META_DATA);
			val = appInfo.metaData.getString(key);
			if (val == null) {
				Log.e(TAG, "please set config value for " + key
						+ " in manifest.xml first");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return val;
	}

	/**
	 * 读取manifest.xml中application标签下的配置项
	 * 
	 * @param key
	 *            键名
	 * @return 返回字符串
	 */
	public static int getConfigInt(Context context, String key) {
		int val = 0;
		try {
			ApplicationInfo appInfo = context.getPackageManager()
					.getApplicationInfo(context.getPackageName(),
							PackageManager.GET_META_DATA);
			val = appInfo.metaData.getInt(key);
		} catch (NameNotFoundException e) {
			Log.e(TAG, e.toString());
		}
		return val;
	}

	/**
	 * 读取manifest.xml中application标签下的配置项
	 * 
	 * @param key
	 *            键名
	 * @return 返回字符串
	 */
	public static boolean getConfigBoolean(Context context, String key) {
		boolean val = false;
		try {
			ApplicationInfo appInfo = context.getPackageManager()
					.getApplicationInfo(context.getPackageName(),
							PackageManager.GET_META_DATA);
			val = appInfo.metaData.getBoolean(key);
		} catch (NameNotFoundException e) {
			Log.e(TAG, e.toString());
		}
		return val;
	}

	/**
	 * 获取屏幕尺寸
	 * 
	 * @return
	 */
	public static String getScreenSize(Context context) {
		WindowManager wm = (WindowManager) context
				.getSystemService(Context.WINDOW_SERVICE);

		int screenWidth = wm.getDefaultDisplay().getWidth();// 屏幕宽度

		int screenHeight = wm.getDefaultDisplay().getHeight();// 屏幕高度

		return screenWidth + " x " + screenHeight;
	}

	/**
	 * 获取屏幕密度
	 * 
	 * @return
	 */
	public static String getScreenScale(Context context) {
		float scale = context.getResources().getDisplayMetrics().density;
		return String.valueOf(scale);
	}

	/**
	 * 指定的activity所属的应用，是否是当前手机的顶级
	 * 
	 * @param context
	 *            activity界面或者application
	 * @return 如果是，返回true；否则返回false
	 */
	public static boolean isTopApplication(Context context) {
		if (context == null) {
			return false;
		}

		try {
			String packageName = context.getPackageName();
			ActivityManager activityManager = (ActivityManager) context
					.getSystemService(Context.ACTIVITY_SERVICE);
			List<RunningTaskInfo> tasksInfo = activityManager
					.getRunningTasks(1);
			if (tasksInfo.size() > 0) {
				// 应用程序位于堆栈的顶层
				if (packageName.equals(tasksInfo.get(0).topActivity
						.getPackageName())) {
					return true;
				}
			}
		} catch (Exception e) {
			// 什么都不做
			Log.e(TAG, e.toString());
		}
		return false;
	}

	/**
	 * 判断APP是否已经打开
	 * 
	 * @param context
	 *            activity界面或者application
	 * @return true表示已经打开 false表示没有打开
	 */
	public static boolean isAppOpen(Context context) {
		ActivityManager mManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		List<RunningAppProcessInfo> mRunningApp = mManager
				.getRunningAppProcesses();
		int size = mRunningApp.size();
		for (int i = 0; i < size; i++) {
			if (context.getPackageName().equals(mRunningApp.get(i).processName)) {
				Log.e(TAG, "接收闹钟   找到进程");
				return true;
			}
		}
		return false;
	}

	/**
	 * 动态获取资源id
	 * 
	 * @param context
	 *            activity界面或者application
	 * @param name
	 *            资源名
	 * @param defType
	 *            资源所属的类 drawable, id, string, layout等
	 * @return 资源id
	 */
	public static int getIdentifier(Context context, String name, String defType) {
		return context.getResources().getIdentifier(name, defType,
				context.getPackageName());
	}

	/**
	 * Check if ActionBar is available.
	 * 
	 * @return
	 */
	public static boolean hasActionBar() {
		return Build.VERSION.SDK_INT >= HONEYCOMB;
	}

	/**
	 * 根据APK路径获取版本信息
	 * 
	 * @param context
	 * @param filePath
	 * @return
	 */
	public static PackageInfo getPackageInfoByApkPath(Context context,
			String filePath) {
		PackageManager pm = context.getPackageManager();
		PackageInfo packageInfo = pm.getPackageArchiveInfo(filePath,
				PackageManager.GET_ACTIVITIES);

		return packageInfo;
	}

	/**
	 * 根据包名获取版本信息
	 * 
	 * @param context
	 * @param packageName
	 * @return
	 */
	public static PackageInfo getPackageInfoByPackageName(Context context,
			String packageName) {
		PackageInfo packageInfo = null;
		try {
			packageInfo = context.getApplicationContext().getPackageManager()
					.getPackageInfo(packageName, 0);
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		return packageInfo;
	}

	public static Location getPhoneLocation(Context context) {
		Location location = null;
		LocationManager locationManager = (LocationManager) context
				.getSystemService(Context.LOCATION_SERVICE);

		Criteria criteria = new Criteria();
		criteria.setCostAllowed(false);// 设置位置服务免费
		criteria.setAccuracy(Criteria.ACCURACY_COARSE);// 置水平位置精度
		String providerName = locationManager.getBestProvider(criteria, true);

		if (providerName != null) {
			location = locationManager.getLastKnownLocation(providerName);
		}

		return location;
	}

	/**
	 * 获取系统当前SDK版本
	 */
	public static int getAndroidSDKVersion() {
		int version = 0;
		try {
			version = Integer.valueOf(android.os.Build.VERSION.SDK);
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
		return version;
	}

	public static String getContent(String src, String startTag, String endTag) {
		String content = src;
		int start = src.indexOf(startTag);
		start += startTag.length();

		try {
			if (endTag != null) {
				int end = src.indexOf(endTag);
				content = src.substring(start, end);
			} else {
				content = src.substring(start);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return content;
	}

	public static String chooseMethod(Context context) {
		TelephonyManager telManager = (TelephonyManager) context
				.getSystemService(Context.TELEPHONY_SERVICE);
		String operator = telManager.getSimOperator();
		if (operator != null) {

			if (operator.equals("46000") || operator.equals("46002") || operator.equals("46007")) {
				// 中国移动
				return "YD";
			} else if (operator.equals("46001")) {
				// 中国联通
				return "LT";
			} else if (operator.equals("46003")) {
				// 中国电信
				return "DX";
			}
		}
		return "";
	}

	public static String getAppMetadata(Context _context, String _metaname) {
		String _metadata = null;
		try {
			PackageManager _packageManager = _context.getPackageManager();
			ApplicationInfo _activityInfo = _packageManager.getApplicationInfo(_context.getPackageName(), PackageManager.GET_META_DATA);
			_metadata = _activityInfo.metaData.getString(_metaname);
		} catch (PackageManager.NameNotFoundException e) {
			_metadata = "error:"+_metaname;
		}
		XLog.d(_metaname + " => " + _metadata);
		return _metadata;
	}
}

package com.qufan.texas.util;

import java.io.UnsupportedEncodingException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;
import java.util.Locale;
import java.util.UUID;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.os.BatteryManager;


public class DeviceUtil {
	protected static final String PREFS_FILE = "device_id.xml";
	protected static final String PREFS_DEVICE_ID = "device_id";
	public static String CHANNEL = "Auto";

	public static UUID deviceUuid;
	public static String deviceModel;
	public static String deviceVersion;
	public static int deviceSdkVersion;
	public static String language = null;
	public static int batteryPower;

	public static int softVersion;
	public static float wb = 1.0F;
	public static float hb = 1.0F;
	public static String telId;
	private static Context context ;
	public static int screenWidth;
	public static int screenHeight;
	public static int[] SCREEN = {1920,1080};
	public DeviceUtil(Context context) {
		DeviceUtil.context = context;
		initDevice(context);
		initUUID(context);
		initLanguage(context);
		DisplayMetrics dm = context.getResources().getDisplayMetrics();
		screenWidth = dm.widthPixels;
		screenHeight = dm.heightPixels;
		int width =  screenWidth;
		int height = screenHeight;
		if(width<height){
			int tempW = width;
			width = height;
			height = tempW;
		}
		if ((width != 0) && (height != 0)) {
			wb = width / SCREEN[0];
			hb = height / SCREEN[1];
		}

		startBatteryMonitor(context);
	}

	public static  int oldWidth(int width){
		return (int)(width/wb);
	}
	public static int oldHeight(int height){
		return (int)(height/hb);
	}

	// //////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private void initDevice(Context context) {
		deviceModel = Build.MODEL;
		deviceSdkVersion = Build.VERSION.SDK_INT;
		deviceVersion = Build.VERSION.RELEASE;

		PackageManager pmgr = context.getPackageManager();
		try {
			PackageInfo packInfo = pmgr.getPackageInfo(context.getPackageName(), 0);
			softVersion = packInfo.versionCode;
		} catch (NameNotFoundException e) {
		}
	}
	
	public static String getDeviceID(Context context) {
		String deviceID = "";
		try {
			final String deviceId = ((TelephonyManager) context
						.getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();
			deviceID = deviceId != null ? deviceId : Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return (deviceID==null?"unKnown":deviceID);
	}

	private void initLanguage(Context context) {
		context.registerReceiver(new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				if (Intent.ACTION_LOCALE_CHANGED.equals(intent.getAction())) {
					Locale locale = Locale.getDefault();
					language = locale.getLanguage() + "_" + locale.getCountry();
				}
			}
		}, new IntentFilter(Intent.ACTION_LOCALE_CHANGED));
		Locale locale = Locale.getDefault();
		language = locale.getLanguage() + "_" + locale.getCountry();
	}

	private void initUUID(Context context) {
		if (deviceUuid == null) {
			synchronized (DeviceUtil.class) {
				if (deviceUuid == null) {
					final SharedPreferences prefs = context.getSharedPreferences(PREFS_FILE, 0);
					final String id = prefs.getString(PREFS_DEVICE_ID, null);

					if (id != null) {
						deviceUuid = UUID.fromString(id);
					}
					else {
						final String androidId = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);
						try {
							if (!"9774d56d682e549c".equals(androidId)) {
								deviceUuid = UUID.nameUUIDFromBytes(androidId.getBytes("utf8"));
							}
							else {
								final String deviceId = ((TelephonyManager) context
										.getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();
								deviceUuid = deviceId != null ? UUID.nameUUIDFromBytes(deviceId.getBytes("utf8"))
										: UUID.randomUUID();
							}
						} catch (UnsupportedEncodingException e) {
							throw new RuntimeException(e);
						}
						prefs.edit().putString(PREFS_DEVICE_ID, deviceUuid.toString()).commit();
					}
				}
			}
		}
	}
	
	
	 public static String getIp(){
			String ip="";
			//获取wifi服务  
	        WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);  
	        //判断wifi是否开启  
	        if (wifiManager.isWifiEnabled()) {  
	        	 WifiInfo wifiInfo = wifiManager.getConnectionInfo();       
	             int ipAddress = wifiInfo.getIpAddress();   
	             ip = intToIp(ipAddress); 
	        } else {
	        	try  
	            {
	        	for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();)  
	            {  
	               NetworkInterface intf = en.nextElement();  
	               for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();)  
	               {  
	                   InetAddress inetAddress = enumIpAddr.nextElement();  
	                   if (!inetAddress.isLoopbackAddress())  
	                   {  
	                       return inetAddress.getHostAddress().toString();  
	                   }  
	               } 
	            }
	            }catch (Exception ex)  
	            {  
	            	return "";  
	            }
	        }
			return ip;
		}
		
	 
	 private static String intToIp(int i) {       
	        return (i & 0xFF ) + "." + ((i >> 8 ) & 0xFF) + "." + ((i >> 16 ) & 0xFF) + "." + ( i >> 24 & 0xFF) ;  
	   } 



	/** ip去点添0 */
	public static String disposeIp() {
		String[] split = getIp().split("\\.");
		StringBuffer buffer = new StringBuffer();
		for (int i = 0; i < split.length; i++) {
			for (int j = 3; j > split[i].length(); j--) {
				buffer.append("0");
			}
			buffer.append(split[i]);
		}
		return buffer.toString();
	}

	// 开始监测电池电量
	private void startBatteryMonitor(Context context) {
		DeviceUtil.batteryPower = 0;
		// 注册电池电量改变监听器
		context.registerReceiver(new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				String action = intent.getAction();
				if(action.equals(Intent.ACTION_BATTERY_CHANGED)){
					int level = intent.getIntExtra("level", 0);  
					int scale = intent.getIntExtra("scale", 100);
					DeviceUtil.batteryPower = level * 100 / scale;
					
				}
			}
		}, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
	}
}

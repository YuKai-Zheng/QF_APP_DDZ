package com.qufan.texas.util;

import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.File;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;

import com.github.kevinsawicki.http.HttpRequest;
import com.umeng.analytics.MobclickAgent;

public class Tools {
	public static int getJsonInt(JSONObject json, String key) {
		int result = 0;
		try {
			result = json.getInt(key);
		} catch (Exception e) {
		}
		return result;
	}

	public static boolean getJsonBoolean(JSONObject json, String key) {
		boolean result = false;
		try {
			result = json.getBoolean(key);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	public static long getJsonLong(JSONObject json, String key) {
		long result = 0;
		try {
			result = json.getLong(key);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	public static String getJsonString(JSONObject json, String key) {
		String result = null;
		try {
			result = json.getString(key);
		} catch (Exception e) {
		}
		return result;
	}

	public static String getJsonString(JSONObject json, String key, String def) {
		String result = null;
		try {
			result = json.getString(key);
		} catch (Exception e) {
		}
		return (result == null) ? def : result;
	}

	public static void putJsonValue(JSONObject json, String key, Object value) {
		try {
			json.put(key, value);
		} catch (JSONException e) {
		}
	}

	public static JSONObject getJSONObject(JSONObject pack, String key) {
		JSONObject json = null;
		try {
			json = pack.getJSONObject(key);
		} catch (JSONException e) {
		}
		return json;
	}

	public static JSONObject getJSONObject(String str) {
		JSONObject json = null;
		try {
			json = new JSONObject(str);
		} catch (JSONException e) {
		}
		return json;
	}

	public static float getJsonFloat(JSONObject json, String key) {
		float result = 0.0f;
		try {
			result = (float) json.getDouble(key);
		} catch (Exception e) {
		}
		return result;
	}

	public static JSONArray getJsonArray(JSONObject json, String key) {
		JSONArray result = null;
		try {
			result = json.getJSONArray(key);
		} catch (Exception e) {
			
		}
		return result;
	}
	
	public static int getIMSI(Context context)
	   {
	     int imsi = 0;
	     TelephonyManager telmanager = (TelephonyManager)context.getSystemService("phone");
	     String simOp = telmanager.getSimOperator();
	     if (simOp != null)
	     {
	       if ((simOp.indexOf("46000") >= 0) || (simOp.indexOf("46002") >= 0) || (simOp.indexOf("46007") >= 0))
	         imsi = 1;//移动
	       else if (simOp.equals("46001"))
	         imsi = 2;//联通
	       else if (simOp.equals("46003"))
	         imsi = 3;//电信
	     }
	     return imsi;
	   }
	public static String getIp(){
		String ip="";
		//获取wifi服务  
        WifiManager wifiManager = (WifiManager) Util.context.getSystemService(Context.WIFI_SERVICE);  
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
	
	private static String intToIp(int i) {       
        return (i & 0xFF ) + "." + ((i >> 8 ) & 0xFF) + "." + ((i >> 16 ) & 0xFF) + "." + ( i >> 24 & 0xFF) ;  
   } 

	private static ExecutorService sExecutorPool = Executors.newFixedThreadPool(3);
	public static void requestApplyAuth(String livePhoto, String spotPhoto,final String url,
			final String mKey,final int mUin,final int cb) {
		final File life = new File(livePhoto);
		final File spot = new File(spotPhoto);
		final Map<String, File> fileMap = new HashMap<String, File>(2);
		fileMap.put("pretty_image", life);
		fileMap.put("normal_image", spot);
        sExecutorPool.submit(new Runnable() {
            @Override
            public void run() {
                HttpRequest post = HttpRequest.post(url)
                        .part("uin", String.valueOf(mUin))
                        .part("key", String.valueOf(mKey));
                if (null != fileMap && fileMap.size() > 0) {
                    Set<Map.Entry<String, File>> entries = fileMap.entrySet();
                    for (Map.Entry<String, File> entry : entries) {
                        String key = entry.getKey();
                        File value = entry.getValue();
                        if (null != entry && null != key && null != value) {
                            post.part(key, value.getAbsolutePath(), value);
                        }
                    }
                }

                final String requestStatus = post.ok() ? post.body() : null;

				Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
					{
                       @Override
                       public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(cb, requestStatus); // -1 失败, 1成功
                      }
                  });
            }
        });
	}
	
	public static boolean isAppOnForeground(Context ctx) {
		ActivityManager activityManager = (ActivityManager) ctx
				.getApplicationContext()//
				.getSystemService(Context.ACTIVITY_SERVICE);
		String packageName = ctx.getApplicationContext().getPackageName();

		List<RunningAppProcessInfo> appProcesses = activityManager
				.getRunningAppProcesses();
		if (appProcesses == null) {
			return false;
		}

		for (RunningAppProcessInfo appProcess : appProcesses) {
			if (appProcess.processName.equals(packageName)
					&& appProcess.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
				return true;
			}
		}
		return false;
	}
	public static void exitsure(Context context) {
//		AppActivity.mStartRecord.exitApp();
//		Log.e("ZIMON", "数据统计结束");
		System.exit(0);
		MobclickAgent.onKillProcess(context);
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	public static boolean copyFile(String oldPath, String newPath) {
       	try { 
           int bytesum = 0; 
           int byteread = 0; 
           File oldfile = new File(oldPath); 
           if (oldfile.exists()) { //文件存在时 
           		File newfile = new File(newPath); 
           		if (newfile.exists()) {
           			newfile.delete();
           		}
               InputStream inStream = new FileInputStream(oldPath); //读入原文件 
               FileOutputStream fs = new FileOutputStream(newPath); 
               byte[] buffer = new byte[32*1024]; 
               int length; 
               while ( (byteread = inStream.read(buffer)) != -1) { 
                   bytesum += byteread; //字节数 文件大小 
                   System.out.println(bytesum); 
                   fs.write(buffer, 0, byteread); 
               } 
               inStream.close(); 
           } 
           return true;
       	} 
       	catch (Exception e) { 
			e.printStackTrace(); 
       } 
       return false;
	}
}

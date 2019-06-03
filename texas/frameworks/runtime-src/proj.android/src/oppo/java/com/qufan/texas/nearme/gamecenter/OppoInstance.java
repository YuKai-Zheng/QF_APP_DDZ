package com.qufan.texas.nearme.gamecenter;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;
import java.util.HashMap;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.app.Notification;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;
import android.content.Intent;
import android.content.IntentFilter;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.Bundle;

import com.qufan.texas.util.PackageUtil;
import com.qufan.texas.util.Tools;
import com.qufan.util.XLog;

import com.nearme.game.sdk.GameCenterSDK;
import com.nearme.game.sdk.callback.ApiCallback;
import com.nearme.game.sdk.callback.GameExitCallback;
import com.nearme.game.sdk.common.model.biz.ReportUserGameInfoParam;
import com.nearme.game.sdk.common.model.biz.ReqUserInfoParam;
import com.nearme.game.sdk.common.util.AppUtil;

public class OppoInstance {
    private static final String TAG = "OppoInstance";
    private static Activity mActivity = null;
    private static int mLoginType = 0;
    private static int mLoginLuaCallback = -1;
    private static int mGameOverCallback = -1;
    private static String mAppSecret = "";
    private static String mAppId = "";
    private String mIsLoginSuccess = "0"; //标记是否登录成功
    public static JSONObject login_info;
    private static OppoInstance instance;

    public static OppoInstance getInstance(){
        if(instance==null){
            instance = scyOppopay();
        }
        return instance;
    }

    private static synchronized OppoInstance scyOppopay(){
        if(instance==null){
            instance = new OppoInstance();
        }
        return instance;
    }

    public void initSdk(Context context){
        this.mActivity = (Activity)context;

        mAppId = PackageUtil.getConfigString(context, "app_key");

        mAppSecret = "517c539aee7075072ec86C6C9D9BE754";

        GameCenterSDK.init(mAppSecret, this.mActivity);
    }

    //切换账号
    protected void doSdkSwitchAccount() {
        
    }

    //登录
    public void login(int loginType, int loginCb, int gameOverCb){
        mLoginType = loginType;
        mLoginLuaCallback = loginCb;
        mGameOverCallback = gameOverCb;
        GameCenterSDK.getInstance().doLogin(mActivity, new ApiCallback() {
            @Override
            public void onSuccess(String resultMsg) {
                Toast.makeText(mActivity, resultMsg, Toast.LENGTH_LONG)
                        .show();
                doGetTokenAndSsoid();
            }

            @Override
            public void onFailure(String resultMsg, int resultCode) {
                Toast.makeText(mActivity, resultMsg, Toast.LENGTH_LONG)
                        .show();
            }
        });
    }

    public void doGetTokenAndSsoid() {
        GameCenterSDK.getInstance().doGetTokenAndSsoid(new ApiCallback() {
            @Override
            public void onSuccess(String resultMsg) {
                try {
                    JSONObject json = new JSONObject(resultMsg);
                    String token = json.getString("token"); // URLEncoder.encode("GBK编码", "utf8");
                    String ssoid = json.getString("ssoid");
                    JSONObject info = new JSONObject();
                    String token_encode = "";
                    try {
                        token_encode = URLEncoder.encode(token, "utf8");
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }
                    try {
                        info.put("type", mLoginType);
                        info.put("openid", ssoid);
                        info.put("token", token_encode);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    login_info = info;
                    mIsLoginSuccess = "1";
                    Log.e("oppo登录成功","token = " + token + "ssoid = " + ssoid);
                    Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() 
                    {
                        @Override
                        public void run() {
                            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(mLoginLuaCallback,
                            login_info.toString());
                            Cocos2dxLuaJavaBridge.releaseLuaFunction(mLoginLuaCallback);
                        }
                    });
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(String content, int resultCode) {

            }
        });
    }

    //使用SDK退出接口
    public void doSdkQuit() {
        GameCenterSDK.getInstance().onExit(mActivity,
            new GameExitCallback() {
                @Override
                public void exitGame() {
                    // CP 实现游戏退出操作，也可以直接调用
                    // AppUtil工具类里面的实现直接强杀进程~
                    //AppUtil.exitGameProcess(mActivity);
                    mActivity.finish();
                    Tools.exitsure(mActivity);
                }
            });
    }

    //角色信息采集接口
    public void doSdkGetUserInfoByCP(String playerInfoJson) {
        JSONObject json;
        try {
            json = new JSONObject(playerInfoJson);
            String roleId = Tools.getJsonString(json, "roleId");
            String roleName = Tools.getJsonString(json, "roleName");
            int roleLevel = Tools.getJsonInt(json, "roleLevel");
            String realmId = Tools.getJsonString(json, "realmId");
            String realmName = Tools.getJsonString(json, "realmName");
            String chapter = Tools.getJsonString(json, "chapter");
            int gold = Tools.getJsonInt(json, "gold");
            Map<String,Number> ext = new HashMap<String,Number>();
            ext.put("pointValue", gold);

            // "roleId", "roleName", roleLevel, "realmId", "realmName", "chapter", ext)
            GameCenterSDK.getInstance().doReportUserGameInfoData(
                new ReportUserGameInfoParam(roleId, roleName, roleLevel,
                        realmId, realmName, chapter, ext), new ApiCallback() 
                {
                    @Override
                    public void onSuccess(String resultMsg) {
                        Toast.makeText(mActivity, "拉取角色信息成功",
                                Toast.LENGTH_LONG).show();
                    }

                    @Override
                    public void onFailure(String resultMsg, int resultCode) {
                        Toast.makeText(mActivity, resultMsg,
                                Toast.LENGTH_LONG).show();
                    }
                }
            );
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int checkLogin() {
        if ("1".equals(mIsLoginSuccess) || "2".equals(mIsLoginSuccess)) {
            return 1;
        }
        else {
            return 0;
        }
    }

    public void onResume() {
        // GameCenterSDK.getInstance().onResume(mActivity);
    }

    public void onPause() {
        // GameCenterSDK.getInstance().onPause();
    }
}
package com.qufan.texas.util;

import com.qufan.util.RHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.util.Log;

import com.baidu.voicerecognition.android.Candidate;
import com.baidu.voicerecognition.android.DataUploader;
import com.baidu.voicerecognition.android.VoiceRecognitionClient;
import com.baidu.voicerecognition.android.VoiceRecognitionClient.VoiceClientStatusChangeListener;
import com.baidu.voicerecognition.android.VoiceRecognitionConfig;

import java.util.List;

public class SpeechToText {
    private final static boolean DEBUG = false;
    private final static String TAG = "LYNN";

    private final static String API_KEY = "snUsLblrohWITZuFGrmMQwv6WY7YEGCq";
    private final static String SECRET_KEY = "lSzekZ5AqBjVrtWoayzCYjmfj7cboPde";
    private final static int STT_START_WORK = 0;    //识别工作开始
    private final static int STT_END_WORK = 1;      //识别工作结束
    private final static int STT_REFRESH_TEXT = 2;  //中间结果更新
    private final static int STT_RESULT = 3;        //最终结果
    private final static int STT_USER_CANCEL = 4;   //用户取消
    private final static int STT_ERROR = 5;         //出现错误

    private final static int ERRCODE_TOO_SHORT = 100001;           //录音太短
    private final static int ERRCODE_DEVICE_PREMISSION = 100002;   //无设备权限
    private final static int ERRCODE_NETWORK_EXECEPTION = 100003;  //网络连接异常
    private final static int ERRCODE_UNKNOWN_ERROR = 100004;       //未知错误 

    private static int mStatusCallbackHandler = -1;
    private static int mStatus = 0;
    private static String mResult = "";

	private static Context context = null;
    private VoiceRecognitionClient mASREngine = null;
    private VoiceRecognitionConfig mConfig = null;
    private MyVoiceRecogListener mListener = null;

	public SpeechToText(Context ctx) {
		context = ctx;
	}

    // 开始语音识别
    public int start(int cb) {
        if (mASREngine == null) {
            if (DEBUG) {Log.e(TAG, "Voice recognition component init.");}
            mASREngine = VoiceRecognitionClient.getInstance(context);
            mASREngine.setTokenApis(API_KEY, SECRET_KEY);
            mConfig = new VoiceRecognitionConfig();
            mConfig.setProp(VoiceRecognitionConfig.PROP_INPUT);
            mConfig.setLanguage(VoiceRecognitionConfig.LANGUAGE_CHINESE);
            mConfig.enableVoicePower(true);
            mConfig.enableBeginSoundEffect(RHelper.getValue(RHelper.raw, "bdspeech_recognition_start"));
            mConfig.enableEndSoundEffect(RHelper.getValue(RHelper.raw, "bdspeech_speech_end"));
            mConfig.setVad_version(1);
            mConfig.setmEnableVAD(false);
            mListener = new MyVoiceRecogListener();
        }
        int code = mASREngine.startVoiceRecognition(mListener, mConfig);
        if (DEBUG) {Log.e(TAG, "Voice recognition start. ret="+code);}
        if (code == VoiceRecognitionClient.START_WORK_RESULT_WORKING) {
            mStatusCallbackHandler = cb;
            return 1;
        }
        else {
            mStatusCallbackHandler = -1;
            return 0;
        }
    }
    
    // 取消语音识别
    public void cancel() {
        if (DEBUG) {Log.e(TAG, "Voice recognition cancel.");}
        if (mASREngine != null) {
            mASREngine.stopVoiceRecognition();
        }
    }

    // 结束语音识别
    public void finish() {
        if (DEBUG) {Log.e(TAG, "Voice recognition finish.");}
        if (mASREngine != null){
            mASREngine.speakFinish();
        }
    }

    // 获取语音音量
    public int getVolume() {
        if (mASREngine != null) {
            long vol = mASREngine.getCurrentDBLevelMeter();
            return (int)vol;
        }
        else{
            return 0;
        }
    }

    // 执行lua回调
    private static void excuteLuaCallback(int status, int errcode, String text) {
        mStatus = status;
        mResult = status + "&&" + errcode + "&&" + text;
        if (DEBUG) {Log.e(TAG, "excuteLuaCallback. result=" + mResult);}
        Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mStatusCallbackHandler != -1) {
                    if (DEBUG) {Log.e(TAG, "Call lua callback. " + mResult);}
                    Cocos2dxLuaJavaBridge.callLuaFunctionWithString(mStatusCallbackHandler, mResult);
                    if (mStatus == STT_RESULT || mStatus == STT_USER_CANCEL || mStatus == STT_ERROR) {
                        if (DEBUG) {Log.e(TAG, "Release lua handler. \n =============================");}
                        releaseLuaCallback();
                    }
                }
                else {
                    if (DEBUG) {Log.e(TAG, "Lua callback is null!!");}
                }
            }
        });
    }
    // 释放lua回调
    private static void releaseLuaCallback() {
        if (mStatusCallbackHandler != -1) {
            Cocos2dxLuaJavaBridge.releaseLuaFunction(mStatusCallbackHandler);
            mStatusCallbackHandler = -1;
        }
    }
    // 解析识别结果
    private String getRecognitionResult(Object result) {
        String recogResult = "";
        if (result != null && result instanceof List) {
            List results = (List) result;
            if (results.size() > 0) {
                if (results.get(0) instanceof List) {
                    List<List<Candidate>> sentences = (List<List<Candidate>>) result;
                    for (List<Candidate> candidates : sentences) {
                        if (candidates != null && candidates.size() > 0) {
                            recogResult = candidates.get(0).getWord();
                            break;
                        }
                    }
                } else {
                    recogResult = results.get(0).toString();
                }
            }
        }
        return recogResult;
    }

    //获取错误信息
    private String getExceptionMessage(int errorCode) {
        String msg = "";
        switch (errorCode) {
            case VoiceRecognitionClient.ERROR_CLIENT_NO_SPEECH:
                msg = "用户没有说话";
                break;
            case VoiceRecognitionClient.ERROR_CLIENT_TOO_SHORT:
                msg = "用户说话声太短";
                break;
            case VoiceRecognitionClient.ERROR_CLIENT_WHOLE_PROCESS_TIMEOUT:
                msg = "解析过程超时";
                break;
            case VoiceRecognitionClient.ERROR_RECORDER_UNAVAILABLE:
                msg = "录音不可用";
                break;
            case VoiceRecognitionClient.ERROR_RECORDER_INTERCEPTED:
                msg = "录音中断";
                break;
            case VoiceRecognitionClient.ERROR_NETWORK_UNUSABLE:
                msg = "网络不可用";
                break;
            case VoiceRecognitionClient.ERROR_NETWORK_CONNECT_ERROR:
                msg = "网络连接错误";
                break;
            case VoiceRecognitionClient.ERROR_NETWORK_PARSE_ERROR:
                msg = "网络解析错误";
                break;
            case VoiceRecognitionClient.ERROR_SERVER_PARAMETER_ERROR:
                msg = "服务器参数错误";
                break;
            case VoiceRecognitionClient.ERROR_SERVER_BACKEND_ERROR:
                msg = "服务器返回错误";
                break;
            case VoiceRecognitionClient.ERROR_SERVER_RECOGNITION_ERROR:
                msg = "服务器识别错误";
                break;
            case VoiceRecognitionClient.ERROR_SERVER_SPEECH_QUALITY_ERROR:
                msg = "语音质量低";
                break;
            case VoiceRecognitionClient.ERROR_SERVER_SPEECH_TOO_LONG:
                msg = "录音过长";
                break;
            case VoiceRecognitionClient.ERROR_NETWORK_TIMEOUT:
                msg = "网络连接超时";
                break;
            default:
                msg = "未知错误";
                break;
        }
        msg = msg + ". 错误码:" + errorCode;
        return msg;
    }

    /**
     * 重写用于处理语音识别回调的监听器
     */
    class MyVoiceRecogListener implements VoiceClientStatusChangeListener {
        @Override
        public void onClientStatusChange(int status, Object obj) {
            switch (status) {
                // 语音识别实际开始，这是真正开始识别的时间点，需在界面提示用户说话。
                case VoiceRecognitionClient.CLIENT_STATUS_START_RECORDING:
                    if(DEBUG) {Log.e(TAG, "onStatusChanged: start recording");}
                    excuteLuaCallback(STT_START_WORK, 0, "");
                    break;
                case VoiceRecognitionClient.CLIENT_STATUS_SPEECH_START: // 检测到语音起点
                    if(DEBUG) {Log.e(TAG, "onStatusChanged: get speech start");}
                    break;
                // 已经检测到语音终点，等待网络返回
                case VoiceRecognitionClient.CLIENT_STATUS_SPEECH_END:
                    if(DEBUG) {Log.e(TAG, "onStatusChanged: get speech end");}
                    excuteLuaCallback(STT_END_WORK, 0, "");
                    break;
                // 语音识别完成，返回结果
                case VoiceRecognitionClient.CLIENT_STATUS_FINISH:
                    String result = getRecognitionResult(obj);
                    if(DEBUG) {Log.e(TAG, "onStatusChanged: finish. result="+result);}
                    if (result.length() > 0) {
                        excuteLuaCallback(STT_RESULT, 0, result);
                    }
                    else {
                        excuteLuaCallback(STT_ERROR, ERRCODE_UNKNOWN_ERROR, "无法识别");
                    }
                    break;
                // 处理连续上屏
                case VoiceRecognitionClient.CLIENT_STATUS_UPDATE_RESULTS:
                    //暂不处理
                    break;
                // 用户取消
                case VoiceRecognitionClient.CLIENT_STATUS_USER_CANCELED:
                    if(DEBUG) {Log.e(TAG, "onStatusChanged: cancel.");}
                    excuteLuaCallback(STT_USER_CANCEL, 0, "");
                    break;
                default:
                    if(DEBUG) {Log.e(TAG, "onStatusChanged: status=" + status);}
                    break;
            }

        }

        @Override
        public void onError(int errorType, int errorCode) {
            String msg = getExceptionMessage(errorCode);
            if(DEBUG) {Log.e(TAG, "onError: " + msg);}
            if (errorType == VoiceRecognitionClient.ERROR_NETWORK) {
                excuteLuaCallback(STT_ERROR, ERRCODE_NETWORK_EXECEPTION, msg);
            }
            else if (errorCode == VoiceRecognitionClient.ERROR_CLIENT_NO_SPEECH 
                    || errorCode == VoiceRecognitionClient.ERROR_CLIENT_TOO_SHORT) {
                excuteLuaCallback(STT_ERROR, ERRCODE_TOO_SHORT, msg);
            }
            else {
                excuteLuaCallback(STT_ERROR, ERRCODE_UNKNOWN_ERROR, msg);
            }
        }

        @Override
        public void onNetworkStatusChange(int status, Object obj) {
            if(DEBUG) {Log.e(TAG, "onNetworkStatusChanged: "+status);}
        }
    }
}

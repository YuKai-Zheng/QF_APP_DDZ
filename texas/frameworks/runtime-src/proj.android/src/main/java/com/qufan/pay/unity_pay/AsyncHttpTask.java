package com.qufan.pay.unity_pay;

import android.os.Handler;
import android.os.Looper;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.Thread;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.net.MalformedURLException;
import java.util.Map;


/**
 * Created by dantezhu on 16/4/14.
 * 异步http请求
 */

public class AsyncHttpTask {

    Thread thread = null;
    static final Handler handler = new Handler(Looper.getMainLooper());

    AsyncHttpListener httpListener;

    public AsyncHttpTask(AsyncHttpListener httpListener) {
        this.httpListener = httpListener;
    }

    public Thread getThread() {
        return thread;
    }

    public void start(final AsyncHttpParams httpParams) {
        thread = new Thread(new Runnable() {
            @Override
            public void run() {
                doInBackground(httpParams);
            }
        });
        thread.start();
    }

    public void stop() {
        if (thread != null && thread.isAlive()) {
            // 终止
            try {
                thread.interrupt();
            }
            catch (Exception e) {
            }
        }
    }

    private void doInBackground(AsyncHttpParams httpParams) {

        // HttpURLConnection 有个内部bug，如果触发readtimeout，底层会自动重发一次
        // 参考: http://stackoverflow.com/questions/27094544/android-java-httpurlconnection-silent-retry-on-read-timeout/30245868#30245868
        HttpURLConnection connection = null;
        String strUrl = httpParams.url;
        URL url = null;

        try {
            if (httpParams.method == AsyncHttpParams.METHOD_GET) {
                if (!httpParams.params.isEmpty()) {
                    strUrl += "?" + convertMapToHttpBody(httpParams.params);
                }

                url = new URL(strUrl);
                connection = (HttpURLConnection)url.openConnection();
                connection.setRequestMethod("GET");
                connection.setUseCaches(false);
                connection.setConnectTimeout((int)httpParams.timeout * 1000);
                connection.setReadTimeout((int)httpParams.timeout * 1000);
            }
            else if (httpParams.method == AsyncHttpParams.METHOD_POST) {
                url = new URL(strUrl);
                connection = (HttpURLConnection)url.openConnection();
                connection.setRequestMethod("POST");
                // 必须在outputstream之前，否则会报错
                connection.setUseCaches(false);
                connection.setConnectTimeout((int)httpParams.timeout * 1000);
                connection.setReadTimeout((int)httpParams.timeout * 1000);

                if (!httpParams.params.isEmpty()) {
                    connection.setDoOutput(true);
                    OutputStream osBody = connection.getOutputStream();
                    osBody.write(convertMapToHttpBody(httpParams.params).getBytes());
                    osBody.flush();
                    osBody.close();
                }
            }
            else {
                XLog.e("method invalid: " + httpParams.method);
                onResult(Constants.RESULT_HTTP_PARAMS_INVALID, null);
                return;
            }

            // 执行
            InputStream inputStream = connection.getInputStream();

            if (!(connection.getResponseCode() >= 200 || connection.getResponseCode() < 400)) {
                XLog.e("http fail. code: " + connection.getResponseCode() + ", msg: " + connection.getResponseMessage());
                onResult(Constants.RESULT_HTTP_FAIL, null);
                return;
            }

            String body = convertInputStreamToString(inputStream);
            JSONObject jsonRsp = new JSONObject(body);
            onResult(0, jsonRsp);
        }
        catch (MalformedURLException e) {
            XLog.e("e: " + e);
            onResult(Constants.RESULT_HTTP_PARAMS_INVALID, null);
        }
        catch (IOException e) {
            XLog.e("e: " + e);
            onResult(Constants.RESULT_HTTP_FAIL, null);
        }
        catch (Exception e) {
            XLog.e("e: " + e);
            onResult(Constants.RESULT_EXCEPTION, null);
        }
        finally {
            // 关闭连接
            if (connection != null) {
                try {
                    connection.disconnect();
                }
                catch (Exception e) {
                }
            }
        }
    }

    private void onResult(final int result, final JSONObject jsonRsp) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (result != 0) {
                    httpListener.onFail(result);
                    return;
                }

                httpListener.onSucc(jsonRsp);
            }
        });
    }

    private static String convertInputStreamToString(InputStream is) {
        /*
         * To convert the InputStream to String we use the BufferedReader.readLine()
         * method. We iterate until the BufferedReader return null which means
         * there's no more data to read. Each line will appended to a StringBuilder
         * and returned as String.
         */
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();

        String line = null;
        try {
            while ((line = reader.readLine()) != null) {
                sb.append(line + "\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return sb.toString();
    }

    private static String convertMapToHttpBody(Map<String, String> params) throws UnsupportedEncodingException {
        StringBuilder sb = new StringBuilder();
        int i = 0;
        for(Map.Entry<String, String> entry : params.entrySet()) {
            if (i != 0) {
                sb.append("&");
            }

            sb.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
            sb.append("=");
            sb.append(entry.getValue());

            i ++;
        }

        return sb.toString();
    }
}


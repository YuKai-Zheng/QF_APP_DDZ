package com.qufan.util;

import android.util.Log;

public class XLog {
    /**
     * 对外static调用
     */
    private static Logger instance = getLogger("qufan");

    // 不再对外开放了
    private static Logger getLogger(String tag) {
        return new Logger(tag);
    }

    public static void setLevel(int level) {
        instance.setLevel(level);
    }

    public static void v(String msg){
        instance.verbose(msg);
    }

    public static void d(String msg){
        instance.debug(msg);
    }

    public static void i(String msg){
        instance.info(msg);
    }

    public static void e(String msg){
        instance.error(msg);
    }

    private static class Logger {
        /**
         * log tag
         */
        private String tag = null;//application name
        private int level = Log.ERROR; // 默认级别

        public Logger(String tag) {
            this.tag = tag;
        }

        public void setLevel(int level) {
            this.level = level;
        }

        private String createMessage(String msg) {
            try {
                StackTraceElement st = Thread.currentThread().getStackTrace()[5];

                return String.format(
                        "[%s:%d %s] %s",
                        st.getFileName(),
                        st.getLineNumber(),
                        st.getMethodName(),
                        msg
                );
            }
            catch (Exception e) {
                e.printStackTrace();
                return msg;
            }
        }

        public void verbose(String msg){
            if (Log.VERBOSE < this.level) {
                return;
            }

            String message = createMessage(msg);
            Log.v(tag, message);
        }

        public void debug(String msg){
            if (Log.DEBUG < this.level) {
                return;
            }

            String message = createMessage(msg);
            Log.d(tag, message);
        }

        public void info(String msg){
            if (Log.INFO < this.level) {
                return;
            }

            String message = createMessage(msg);
            Log.i(tag, message);
        }

        public void error(String msg){
            if (Log.ERROR < this.level) {
                return;
            }

            String message = createMessage(msg);
            Log.e(tag, message);
        }
    }
}

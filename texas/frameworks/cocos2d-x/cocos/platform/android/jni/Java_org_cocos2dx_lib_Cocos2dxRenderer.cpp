#include "base/CCIMEDispatcher.h"
#include "base/CCDirector.h"
#include "base/CCEventType.h"
#include "base/CCEventCustom.h"
#include "../CCApplication.h"
#include "platform/CCFileUtils.h"
#include "JniHelper.h"
#include <jni.h>

using namespace cocos2d;

extern "C" {

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeRender(JNIEnv* env) {
        cocos2d::Director::getInstance()->mainLoop();
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnPause() {
// ADD-BEGIN by dantezhu in 2015-09-07 16:56:10
// 否则在百度包上，游戏打开瞬间偶尔会崩溃
// 09-07 16:31:12.913: D/SoundPool(20081): autoResume()
// 09-07 16:31:12.948: D/dalvikvm(20081): GC_FOR_ALLOC freed 3368K, 13% free 23084K/26520K, paused 24ms, total 24ms
// 09-07 16:31:12.953: D/---- onPause ---(20081): cocos2d-x
// 09-07 16:31:12.953: D/SoundPool(20081): autoPause()
// 09-07 16:31:12.958: D/---- onResume ---(20081): cocos2d-x
// 09-07 16:31:12.958: A/libc(20081): Fatal signal 11 (SIGSEGV) at 0x00000000 (code=1), thread 20193 (Thread-3353)
        if (Director::getInstance()->getOpenGLView()) {
// ADD-END
            Application::getInstance()->applicationDidEnterBackground();
            cocos2d::EventCustom backgroundEvent(EVENT_COME_TO_BACKGROUND);
            cocos2d::Director::getInstance()->getEventDispatcher()->dispatchEvent(&backgroundEvent);
// ADD-BEGIN by dantezhu in 2015-09-07 16:56:12
        }
// ADD-END
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnResume() {
        if (Director::getInstance()->getOpenGLView()) {
            Application::getInstance()->applicationWillEnterForeground();
            cocos2d::EventCustom foregroundEvent(EVENT_COME_TO_FOREGROUND);
            cocos2d::Director::getInstance()->getEventDispatcher()->dispatchEvent(&foregroundEvent);
        }
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInsertText(JNIEnv* env, jobject thiz, jstring text) {
        const char* pszText = env->GetStringUTFChars(text, NULL);
        cocos2d::IMEDispatcher::sharedDispatcher()->dispatchInsertText(pszText, strlen(pszText));
        env->ReleaseStringUTFChars(text, pszText);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeDeleteBackward(JNIEnv* env, jobject thiz) {
        cocos2d::IMEDispatcher::sharedDispatcher()->dispatchDeleteBackward();
    }

    JNIEXPORT jstring JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeGetContentText() {
        JNIEnv * env = 0;

        if (JniHelper::getJavaVM()->GetEnv((void**)&env, JNI_VERSION_1_4) != JNI_OK || ! env) {
            return 0;
        }
        std::string pszText = cocos2d::IMEDispatcher::sharedDispatcher()->getContentText();
        return env->NewStringUTF(pszText.c_str());
    }
}

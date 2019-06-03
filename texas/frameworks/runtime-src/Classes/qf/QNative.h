#ifndef __QNATIVE_H__
#define __QNATIVE_H__

#include <string>
#include "cocos2d.h"

class QNative : public cocos2d::Ref
{

public:
	static QNative * shareInstance();
	void init();

    std::string zny_getName(std::string name="hy");
    std::string zny_getUpdatePath(std::string path="file");
	std::string zny_getCachePath(std::string path="file");
    std::string zny_getChannelName(std::string path="channel");
	std::string zny_getKey(int key=1);
    std::string zny_getTeaKey(int key=2);
	std::string zny_getSignKey(int key=3);

	void zny_mkdir( const char * path, int arg=1);
	void zny_rmdir( const char * path, int arg=1);

	cocos2d::Sprite * zny_getCirleImg (const char * mask , const char * file, int arg=2);

	~QNative(){}
	QNative(){}

	void zny_applicationActions(const char * type, int arg=1);
	void zny_setLuaApplicationHanlder(int handler, int arg=1);
	std::string md5(const char * str, int size, int arg=3);

	void zny_getScreenBlurSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius, int arg=3);
	void zny_getScreenGraySprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, int arg=2);
	void zny_getScreenHighlightSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment, int arg=3);
private:
	
	std::string _updatePath ;
	std::string _cachePath ;
	int _luaApplicationActionsHandle;
	
    
    std::string zny_cplus_confuse_1();
    std::string zny_cplus_confuse_2();
    std::string zny_cplus_confuse_3();
    std::string zny_cplus_confuse_4();
    std::string zny_cplus_confuse_5();
    std::string zny_cplus_confuse_6();
    std::string zny_cplus_confuse_7();
    std::string zny_cplus_confuse_8();
    std::string zny_cplus_confuse_9();
    std::string zny_cplus_confuse_10();
    std::string zny_cplus_confuse_11();
    std::string zny_cplus_confuse_12();
};


#endif

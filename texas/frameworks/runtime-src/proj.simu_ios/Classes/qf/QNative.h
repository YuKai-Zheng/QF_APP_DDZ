#ifndef __QNATIVE_H__
#define __QNATIVE_H__

#include <string>
#include "cocos2d.h"

class QNative : public cocos2d::Ref
{

public:
	static QNative * shareInstance();
	void init();

	std::string getName();

	std::string getUpdatePath();
	std::string getCachePath();
	std::string getKey();
    std::string getTeaKey ();

	void mkdir( const char * path);
	void rmdir( const char * path);

	cocos2d::Sprite * getCirleImg (const char * mask , const char * file);

	~QNative(){}
	QNative(){}

	void applicationActions(const char * type);
	void setLuaApplicationHanlder(int handler);
	std::string md5(const char * str);
	std::string md5WithBase64(const std::string &str);

	void getScreenBlurSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius);
	void getScreenGraySprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter);
	void getScreenHighlightSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment);
private:
	
	std::string _updatePath ;
	std::string _cachePath ;
	int _luaApplicationActionsHandle;
	
};


#endif

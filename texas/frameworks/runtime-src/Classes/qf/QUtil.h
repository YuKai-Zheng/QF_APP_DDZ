#ifndef __QUTIL_H__ 
#define __QUTIL_H__
#include <string>
#include "tinyxml2/tinyxml2.h"
#include "unzip/unzip.h"

#define ZIP_BUFFER_SIZE    8192
#define MAX_FILENAME   512
#define MD5_BUFFER_LENGTH 32

class QUtil

{
public:
	
	~QUtil(){}

	static bool zny_mkdir(const char * path);
	static void zny_rmdir(const char * path);
	static bool zny_createDirectory(const char * path);

	static unsigned char zny_getCharFromHex(char a , char b);
	static int zny_getNumberFromHex(char a);
    static const std::string zny_parseXMLToLuaTable(const std::string path);
    static const bool zny_uncompressZip(const std::string& zipName, const std::string& outPath);
private:
	QUtil(){}
    static const std::string zny_parseXmlElement(tinyxml2::XMLElement* element);
    static const std::string zny_parseXmlAttribute(tinyxml2::XMLElement* element);
    
    static std::string zny_qutil_cplus_confuse_1();
    static std::string zny_qutil_cplus_confuse_2();
    static std::string zny_qutil_cplus_confuse_3();
    static std::string zny_qutil_cplus_confuse_4();
    static std::string zny_qutil_cplus_confuse_5();
    static std::string zny_qutil_cplus_confuse_6();
    static std::string zny_qutil_cplus_confuse_7();
};


#endif

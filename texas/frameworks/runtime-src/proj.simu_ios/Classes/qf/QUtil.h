#ifndef __QUTIL_H__ 
#define __QUTIL_H__
#include <string>
#include "tinyxml2/tinyxml2.h"

#define MD5_BUFFER_LENGTH 32

class QUtil

{
public:
	
	~QUtil(){}

	static void mkdir(const char * path);
	static void rmdir(const char * path);

	static unsigned char getCharFromHex(char a , char b);
	static int getNumberFromHex(char a);
    static const std::string parseXMLToLuaTable(const std::string path);
private:
	QUtil(){}
    static const std::string parseXmlElement(tinyxml2::XMLElement* element);
    static const std::string parseXmlAttribute(tinyxml2::XMLElement* element);
};


#endif
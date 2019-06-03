#include <string>
#include "QUtil.h"
#include "cocos2d.h"

using namespace cocos2d;
using namespace std;

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <dirent.h>
#endif

#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS)
#include "code_confuse_for_android.h"
#endif

bool QUtil::zny_mkdir(const char * path) {

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *pDir = NULL;
    pDir = opendir (path);
    if (! pDir)
    {
        ::mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
		cocos2d::log("success create dir = %s" , path);
	}else{
		return false;
	}
    return true;
#else
	if ( GetFileAttributesA(path) == INVALID_FILE_ATTRIBUTES)
	{
		CreateDirectoryA(path, 0);
		cocos2d::log("success create dir = %s" , path);
	}else{
        return false;
	}
    
    zny_qutil_cplus_confuse_1();
    
    return true;
#endif
}
std::string QUtil::zny_qutil_cplus_confuse_1()
{
    std::string as = RM_OCPLUS_KEY;
    return as;
}
/*
 * Create a direcotry is platform depended.
 */
bool QUtil::zny_createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    mode_t processMask = umask(0);
    int ret = ::mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
    umask(processMask);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
#else
    BOOL ret = CreateDirectoryA(path, nullptr);
    if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
    {
        return false;
    }
    zny_qutil_cplus_confuse_2();
    
    return true;
#endif
}
std::string QUtil::zny_qutil_cplus_confuse_2()
{
    std::string as = RM_OCPLUS_SECRET;
    return as;
}
void QUtil::zny_rmdir (const char * path) {

	std::string pathToSave(path);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	std::string command = "rm -r ";
	command += "\"" + pathToSave + "\"";
	system(command.c_str());
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    // empty
#else
	std::string command = "rd /s /q ";
	command += "\"" + pathToSave + "\"";
	system(command.c_str());
#endif

    zny_qutil_cplus_confuse_3();
}
std::string QUtil::zny_qutil_cplus_confuse_3()
{
    std::string as = RM_OCPLUS_SIGN;
    return as;
}

int QUtil::zny_getNumberFromHex(char a){
    
    zny_qutil_cplus_confuse_4();
    
	if ( a >= 'A') {
		return a - 'A' + 10;
	}else{
		return a - '0';
	}
}
std::string QUtil::zny_qutil_cplus_confuse_4()
{
    std::string as = RM_COCOS_KEY;
    return as;
}
unsigned char QUtil::zny_getCharFromHex(char a , char b){
	return zny_getNumberFromHex(a)*16+zny_getNumberFromHex(b);
}

#define XML_ITEM_BUF_LEN    (256)
/******************************************
 解析xml元素的属性, 返回属性的lua表
 例如, <country name="英格兰" location="欧洲" nick="腐国"/>, 解析属性得到:
 attribute={
 name='英格兰',
 location='欧洲',
 nick='腐国'
 }
 *****************************************/
const std::string QUtil::zny_parseXmlAttribute(tinyxml2::XMLElement* element)
{
    if (element == NULL)
    {
        return NULL;
    }
    
    std::string attr_text = "";
    bool first_element = true;
    char value[XML_ITEM_BUF_LEN];
    memset(value, 0, XML_ITEM_BUF_LEN);
    
    const tinyxml2::XMLAttribute *attribute = element->FirstAttribute();
    bool exist = (attribute == NULL) ? false : true;
    if (exist)
    {
        attr_text.append("attributes={");
    }
    
    while(attribute)
    {
        if (!first_element)
        {
            attr_text.append(",");
        }
        
        //属性名
        attr_text.append(attribute->Name());
        attr_text.append("=");
        
        //属性值
        bool boolValue = false;
        double doubleValue = 0;
        float floatValue = 0;
        int intValue = 0;
        unsigned int uintValue = 0;
        
        if (attribute->QueryBoolValue(&boolValue) == tinyxml2::XMLError::XML_SUCCESS)
        {
            if(boolValue)
            {
                strcpy(value, "true");
            }
            else
            {
                strcpy(value, "false");
            }
        }
        else if(attribute->QueryDoubleValue(&doubleValue) == tinyxml2::XMLError::XML_SUCCESS)
        {
            snprintf(value, XML_ITEM_BUF_LEN, "%lf", doubleValue);
        }
        else if(attribute->QueryFloatValue(&floatValue) == tinyxml2::XMLError::XML_SUCCESS)
        {
            snprintf(value, XML_ITEM_BUF_LEN, "%f", floatValue);
        }
        else if(attribute->QueryIntValue(&intValue) == tinyxml2::XMLError::XML_SUCCESS)
        {
            snprintf(value, XML_ITEM_BUF_LEN, "%d", intValue);
        }
        else if(attribute->QueryUnsignedValue(&uintValue) == tinyxml2::XMLError::XML_SUCCESS)
        {
            snprintf(value, XML_ITEM_BUF_LEN, "%d", uintValue);
        }
        else
        {
            const char* attri_value = attribute->Value();
            if(attri_value)
            {
                snprintf(value, XML_ITEM_BUF_LEN, "'%s'", attri_value);
            }
            else
            {
                strcpy(value, "''");
            }
        }
        attr_text.append(value);
        attribute = attribute->Next();
        first_element = false;
    }
    
    if (exist)
    {
        //返回属性表
        attr_text.append("}");
    }
    
    zny_qutil_cplus_confuse_5();
    
    return attr_text;
}
std::string QUtil::zny_qutil_cplus_confuse_5()
{
    std::string as = RM_COCOS_SECRET;
    return as;
}
/******************************************
 解析xml元素, 返回包含名字、属性、文本、子元素的lua表
 ******************************************/
const std::string QUtil::zny_parseXmlElement(tinyxml2::XMLElement* element)
{
    if (element == NULL)
    {
        return "";
    }
    
    //xml元素的lua表
    std::string luatab = "{";
    
    //xml元素名描述
    luatab.append("name='");
    luatab.append(element->Name());
    luatab.append("'");
    
    //xml元素属性表
    const std::string element_attribute = zny_parseXmlAttribute(element);
    if(element_attribute.length() > 0)
    {
        luatab.append(",");
        luatab.append(element_attribute);
    }
    
    //xml元素文本
    const char* text = element->GetText();
    if(text) {
        luatab.append(",text='");
        luatab.append(text);
        luatab.append("'");
    }
    
    //xml元素的子元素
    tinyxml2::XMLElement *child = element->FirstChildElement();
    bool exist_child = (child == NULL) ? false : true;
    if (exist_child)
    {
        luatab.append(",elements={");
    }
    //开始递归查找(子元素索引, 按lua索引规则从1开始)
    unsigned int index = 1;
    char buffer[XML_ITEM_BUF_LEN];
    while(child)
    {
        const std::string& sub_table = zny_parseXmlElement(child);
        if(sub_table.length() > 0)
        {
            if(index > 1)
            {
                luatab.append(",");
            }
            memset(buffer, 0, XML_ITEM_BUF_LEN);
            snprintf(buffer, XML_ITEM_BUF_LEN, "[%d]=", index);
            luatab.append(buffer);
            luatab.append(sub_table);
            index += 1;
        }
        child = child->NextSiblingElement();
    }
    if (exist_child)
    {
        luatab.append("}");
    }
    
    luatab.append("}");
    
    zny_qutil_cplus_confuse_6();
    
    return luatab;
}
std::string QUtil::zny_qutil_cplus_confuse_6()
{
    std::string as = RM_COCOS_SIGN;
    return as;
}
/******************************************
    解析xml文件,遍历所有标签,转化为Lua表. 例如:
    <?xml version="1.0"?>
    <country flag="中国">
        <city flag="北京" location="华北">京腔</city>
        <city flag="上海" location="华东">吴语</city>
        <city flag="广州" location="华东">粤语</city>
        <city flag="深圳" location="华南">
            <main>普通话</main>
            <sub>粤语</sub>
            <sub>闽南语</sub>
            <sub>四川话</sub>
        </city>
    </country>
    转换为lua表后得到:
    {
        name='country',
        attributes={flag='中国'},
        elements=
        {
            1=
            {
                name='city',
                attributes={flag='北京',location='华北'},
                text='京腔'
            },
            2=
            {
                name='city',
                attributes={flag='上海',location='华东'},
                text='吴语'
            },
            3=
            {
                name='city',
                attributes={flag='广州',location='华南'},
                text='粤语'
            },
            4=
            {
                name='city',
                attributes={flag='深圳',location='华南'},
                elements=
                {
                    1={name='main',text='普通话'},
                    2={name='sub',text='粤语'},
                    3={name='sub',text='闽南语'},
                    4={name='sub',text='四川话'}
                }
            }
        }
    }
 ******************************************/
const std::string QUtil::zny_parseXMLToLuaTable(const std::string path)
{
    std::string file_content = FileUtils::getInstance()->getStringFromFile(path);
    tinyxml2::XMLDocument document;
    document.Parse(file_content.c_str());
    tinyxml2::XMLElement *root = document.RootElement();
    if(!root)
    {
        CCLOG("parseXMLToLuaTable. parse %s failed", file_content.c_str());
    }
    const std::string& lua_tabel = zny_parseXmlElement(root);
    
    zny_qutil_cplus_confuse_7();
    
    return lua_tabel;
}
std::string QUtil::zny_qutil_cplus_confuse_7()
{
    std::string as = RM_UNITY_KEY;
    return as;
}
const bool QUtil::zny_uncompressZip(const std::string& zipName, const std::string& outPath)
{
    // Open the zip file
    unzFile zipfile = unzOpen(zipName.c_str());
    if (! zipfile)
    {
        CCLOG("can not open zip file %s", zipName.c_str());
        return false;
    }
    
    // Get info about the zip file
    unz_global_info global_info;
    if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
    {
        CCLOG("can not read file global info of %s", zipName.c_str());
        unzClose(zipfile);
        return false;
    }
    
    // Buffer to hold data read from the zip file
    char readBuffer[ZIP_BUFFER_SIZE];
    
    CCLOG("start uncompressing");
	zny_createDirectory(outPath.c_str());
    
    // Loop to extract all files.
    uLong i;
    for (i = 0; i < global_info.number_entry; ++i)
    {
        // Get info about current file.
        unz_file_info fileInfo;
        char fileName[MAX_FILENAME];
        if (unzGetCurrentFileInfo(zipfile,
                                  &fileInfo,
                                  fileName,
                                  MAX_FILENAME,
                                  nullptr,
                                  0,
                                  nullptr,
                                  0) != UNZ_OK)
        {
            CCLOG("can not read file info");
            unzClose(zipfile);
            return false;
        }
        
        const string fullPath = outPath + fileName;
        
        // Check if this entry is a directory or a file.
        const size_t filenameLength = strlen(fileName);
        if (fileName[filenameLength-1] == '/')
        {
            // Entry is a direcotry, so create it.
            // If the directory exists, it will failed scilently.
            if (!zny_createDirectory(fullPath.c_str()))
            {
                CCLOG("can not create directory %s", fullPath.c_str());
                unzClose(zipfile);
                return false;
            }
        }
        else
        {
            //There are not directory entry in some case.
            //So we need to test whether the file directory exists when uncompressing file entry
            //, if does not exist then create directory
            const string fileNameStr(fileName);
            
            size_t startIndex=0;
            
            size_t index=fileNameStr.find("/",startIndex);
            
            while(index != std::string::npos)
            {
                const string dir=outPath+fileNameStr.substr(0,index);
                
                FILE *out = fopen(dir.c_str(), "r");
                
                if(!out)
                {
                    if (!zny_createDirectory(dir.c_str()))
                    {
                        CCLOG("can not create directory %s", dir.c_str());
                        unzClose(zipfile);
                        return false;
                    }
                    else
                    {
                        CCLOG("create directory %s",dir.c_str());
                    }
                }
                else
                {
                    fclose(out);
                }
                
                startIndex=index+1;
                
                index=fileNameStr.find("/",startIndex);
                
            }
            
            
            
            // Entry is a file, so extract it.
            
            // Open current file.
            if (unzOpenCurrentFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not open file %s", fileName);
                unzClose(zipfile);
                return false;
            }
            
            // Create a file to store current file.
            FILE *out = fopen(fullPath.c_str(), "wb");
            if (! out)
            {
                CCLOG("can not open destination file %s", fullPath.c_str());
                unzCloseCurrentFile(zipfile);
                unzClose(zipfile);
                return false;
            }
            
            // Write current file content to destinate file.
            int error = UNZ_OK;
            do
            {
                error = unzReadCurrentFile(zipfile, readBuffer, ZIP_BUFFER_SIZE);
                if (error < 0)
                {
                    CCLOG("can not read zip file %s, error code is %d", fileName, error);
                    unzCloseCurrentFile(zipfile);
                    unzClose(zipfile);
                    return false;
                }
                
                if (error > 0)
                {
                    fwrite(readBuffer, error, 1, out);
                }
            } while(error > 0);
            
            fclose(out);
        }
        
        unzCloseCurrentFile(zipfile);
        
        // Goto next entry listed in the zip file.
        if ((i+1) < global_info.number_entry)
        {
            if (unzGoToNextFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not read next file");
                unzClose(zipfile);
                return false;
            }
        }
    }
    
    CCLOG("end uncompressing");
    unzClose(zipfile);
    
    return true;
}

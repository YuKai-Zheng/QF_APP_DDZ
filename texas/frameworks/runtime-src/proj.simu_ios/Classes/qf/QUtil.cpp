#include <string>
#include "QUtil.h"
#include "cocos2d.h"





using namespace cocos2d;


#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <dirent.h>
#include <sys/stat.h>
#endif


void QUtil::mkdir(const char * path) {

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *pDir = NULL;
    pDir = opendir (path);
    if (! pDir)
    {
        ::mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
		cocos2d::log("success create dir = %s" , path);
	}else{
		
	}
#else
	if ( GetFileAttributesA(path) == INVALID_FILE_ATTRIBUTES)
	{
		CreateDirectoryA(path, 0);
		cocos2d::log("success create dir = %s" , path);
	}else{

	}
#endif

}


void QUtil::rmdir (const char * path) {

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

}


int QUtil::getNumberFromHex(char a){
	if ( a >= 'A') {
		return a - 'A' + 10;
	}else{
		return a - '0';
	}
}

unsigned char QUtil::getCharFromHex(char a , char b){
	return getNumberFromHex(a)*16+getNumberFromHex(b);
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
const std::string QUtil::parseXmlAttribute(tinyxml2::XMLElement* element)
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
    return attr_text;
}
/******************************************
 解析xml元素, 返回包含名字、属性、文本、子元素的lua表
 ******************************************/
const std::string QUtil::parseXmlElement(tinyxml2::XMLElement* element)
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
    const std::string element_attribute = parseXmlAttribute(element);
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
        const std::string& sub_table = parseXmlElement(child);
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
    
    return luatab;
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
const std::string QUtil::parseXMLToLuaTable(const std::string path)
{
    std::string file_content = FileUtils::getInstance()->getStringFromFile(path);
    tinyxml2::XMLDocument document;
    document.Parse(file_content.c_str());
    tinyxml2::XMLElement *root = document.RootElement();
    if(!root)
    {
        CCLOG("parseXMLToLuaTable. parse %s failed", file_content.c_str());
    }
    const std::string& lua_tabel = parseXmlElement(root);
    return lua_tabel;
}

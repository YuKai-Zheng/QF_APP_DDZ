#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

#include "base/ccConfig.h"
#include "qf_manual_bindings.hpp"
#include "QNative.h"
#include "QUtil.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "CCLuaEngine.h"
#include "actions/MoveCircle.h"


int lua_qf_manual_bindings_QNative_md5(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S,1,"QNative",0,&tolua_err)) goto tolua_lerror;
#endif

	cobj = (QNative*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_manual_bindings_QNative_md5'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
#if COCOS2D_DEBUG >= 1
        if (
                !tolua_isstring(tolua_S,2, 0, &tolua_err)
                )
        {
            goto tolua_lerror;
        }
#endif
        size_t size = 0;
        const char* src = lua_tolstring(tolua_S, 2, &size);
		std::string ret = cobj->md5(src, size);
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "md5",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_manual_bindings_QNative_md5'.",&tolua_err);
#endif

	return 0;
}

/**
 #include "qf_manual_bindings.hpp"
 tolua_function(tolua_S,"registerApplicationActions",lua_qf_manual_bindings_register_application_actions);
 
 add code to qf_auto_bindings.cpp
 **/
int lua_qf_manual_bindings_register_application_actions(lua_State* tolua_S){
    
    cocos2d::log("%s"," --- register application actions ---- ");
    
    int argc = 0;
    QNative* cobj = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
    
    
#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"QNative",0,&tolua_err)) goto tolua_lerror;
#endif
    
    cobj = (QNative*)tolua_tousertype(tolua_S,1,0);
    
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_manual_bindings_register_application_actions'", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
#if COCOS2D_DEBUG >= 1
        if (!toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err))
            goto tolua_lerror;
#endif
        
        int handler = (  toluafix_ref_function(tolua_S,2,0));
        cobj->zny_setLuaApplicationHanlder(handler);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "rmdir",argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_qf_manual_bindings_register_application_actions'.",&tolua_err);
#endif
    
    
    return 0;
}

int lua_qf_manual_bindings_QNative_zny_getScreenBlurSprite(lua_State* tolua_S)
{
    QNative* cobj = nullptr;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!!tolua_isusertype(tolua_S,1,"QNative",0,&tolua_err) ||
        !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err) ||
        !tolua_isboolean(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 4, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        cobj = (QNative*)tolua_tousertype(tolua_S,1,0);
        int handler = toluafix_ref_function(tolua_S, 2, 0);
        bool quarter = tolua_toboolean(tolua_S, 3, false);
        double radius = tolua_tonumber(tolua_S, 4, 10);
        
        cobj->zny_getScreenBlurSprite([=](bool succeed, cocos2d::Sprite* sprite ){
            
            cocos2d::LuaEngine::getInstance()->getLuaStack()->pushBoolean(succeed);
            cocos2d::LuaEngine::getInstance()->getLuaStack()->pushObject(sprite, "cc.Sprite");
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 2);
            cocos2d::LuaEngine::getInstance()->removeScriptHandler(handler);
            
        }, quarter, (unsigned int)radius);
        
        return 0;
    }
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'QNative::zny_getScreenBlurSprite'.",&tolua_err);
    return 0;
#endif
}

int lua_qf_manual_bindings_QNative_zny_getScreenGraySprite(lua_State* tolua_S)
{
    QNative* cobj = nullptr;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!!tolua_isusertype(tolua_S,1,"QNative",0,&tolua_err) ||
        !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err) ||
        !tolua_isboolean(tolua_S, 3, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        cobj = (QNative*)tolua_tousertype(tolua_S,1,0);
        int handler = toluafix_ref_function(tolua_S, 2, 0);
        bool quarter = tolua_toboolean(tolua_S, 3, false);
        
        cobj->zny_getScreenGraySprite([=](bool succeed, cocos2d::Sprite* sprite ){
            
            cocos2d::LuaEngine::getInstance()->getLuaStack()->pushBoolean(succeed);
            cocos2d::LuaEngine::getInstance()->getLuaStack()->pushObject(sprite, "cc.Sprite");
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 2);
            cocos2d::LuaEngine::getInstance()->removeScriptHandler(handler);
            
        }, quarter);
        
        return 0;
    }
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'QNative::zny_getScreenGraySprite'.",&tolua_err);
    return 0;
#endif
}

int lua_qf_manual_bindings_QNative_zny_getScreenHighlightSprite(lua_State* tolua_S)
{
    QNative* cobj = nullptr;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!!tolua_isusertype(tolua_S,1,"QNative",0,&tolua_err) ||
        !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err) ||
        !tolua_isboolean(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 4, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        cobj = (QNative*)tolua_tousertype(tolua_S,1,0);
        int handler = toluafix_ref_function(tolua_S, 2, 0);
        bool quarter = tolua_toboolean(tolua_S, 3, false);
        double increment = tolua_tonumber(tolua_S, 4, 10);
        
        cobj->zny_getScreenHighlightSprite([=](bool succeed, cocos2d::Sprite* sprite ){
            
            cocos2d::LuaEngine::getInstance()->getLuaStack()->pushBoolean(succeed);
            cocos2d::LuaEngine::getInstance()->getLuaStack()->pushObject(sprite, "cc.Sprite");
            cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(handler, 2);
            cocos2d::LuaEngine::getInstance()->removeScriptHandler(handler);
            
        }, quarter, (unsigned int)increment);
        
        return 0;
    }
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'QNative::zny_getScreenBlurSprite'.",&tolua_err);
    return 0;
#endif
}

int lua_qf_manual_bindings_MoveCircle_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (argc == 3)
    {
        double arg0;
        cocos2d::Vec2 arg1;
        double arg2;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        ok &= luaval_to_vec2(tolua_S, 3, &arg1);
        ok &= luaval_to_number(tolua_S, 4,&arg2);
        if(!ok)
            return 0;
        MoveCircle* ret = MoveCircle::create(arg0, arg1, arg2);
        object_to_luaval<MoveCircle>(tolua_S, "MoveCircle",(MoveCircle*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 2);
    return 0;
}

static int lua_qf_manual_bindings_MoveCircle_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MoveCircle)");
    return 0;
}

int lua_register_qf_manual_bindings_MoveCircle(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"MoveCircle");
    tolua_cclass(tolua_S,"MoveCircle","MoveCircle","cc.ActionInterval",lua_qf_manual_bindings_MoveCircle_finalize);
    tolua_beginmodule(tolua_S,"MoveCircle");
    tolua_function(tolua_S,"create",lua_qf_manual_bindings_MoveCircle_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(MoveCircle).name();
    g_luaType[typeName] = "MoveCircle";
    g_typeCast["MoveCircle"] = "MoveCircle";
    return 1;
}


int lua_qf_manual_bindings_zny_parseXml(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
    
    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2, &arg0);
        
        if(!ok)
            return 0;
        std::string ret = QUtil::zny_parseXMLToLuaTable(arg0);
		tolua_pushcppstring(tolua_S, ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "parseXml", argc, 1);
    return 0;
}

int lua_register_qf_manual_bindings_zny_xmlParser(lua_State* tolua_S)
{
    if (nullptr == tolua_S)
        return 0;
    
    tolua_open(tolua_S);
    tolua_module(tolua_S, "QXml", 0);
    tolua_beginmodule(tolua_S,"QXml");
    tolua_function(tolua_S, "decode", lua_qf_manual_bindings_zny_parseXml);
    tolua_endmodule(tolua_S);
    
    return 0;
}

int lua_qf_manual_bindings_zny_uncompressZip(lua_State* tolua_S)
{
    int argc = 0;
    bool ok = true;
    argc = lua_gettop(tolua_S) - 1;
    if (argc == 2)
    {
        std::string argc0;
        std::string argc1;
        ok &= luaval_to_std_string(tolua_S, 2, &argc0);
        ok &= luaval_to_std_string(tolua_S, 3, &argc1);

        if (!ok)
            return 0;
		bool ret = QUtil::zny_uncompressZip(argc0, argc1);
        tolua_pushboolean(tolua_S, (bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "uncompressZip", argc, 2);
    return 0;
}
int lua_register_qf_manual_bindings_zny_uncompressZip(lua_State* tolua_S)
{
    if (nullptr == tolua_S)
        return 0;

    tolua_open(tolua_S);
    tolua_module(tolua_S, "QUtil", 0);
    tolua_beginmodule(tolua_S, "QUtil");
    tolua_function(tolua_S, "uncompressZip", lua_qf_manual_bindings_zny_uncompressZip);
    tolua_endmodule(tolua_S);

    return 0;
}

int lua_register_qf_manual_bindings_QNative(lua_State* tolua_S)
{
    if (nullptr == tolua_S)
        return 0;

    tolua_open(tolua_S);
    tolua_module(tolua_S, "QNative", 0);
    tolua_beginmodule(tolua_S, "QNative");
    tolua_function(tolua_S, "md5", lua_qf_manual_bindings_QNative_md5);
    tolua_endmodule(tolua_S);

    return 0;
}

void lua_register_qf_manual_bindings(lua_State* tolua_S)
{
    lua_register_qf_manual_bindings_MoveCircle(tolua_S);
    lua_register_qf_manual_bindings_zny_xmlParser(tolua_S);
    lua_register_qf_manual_bindings_zny_uncompressZip(tolua_S);
    lua_register_qf_manual_bindings_QNative(tolua_S);
}


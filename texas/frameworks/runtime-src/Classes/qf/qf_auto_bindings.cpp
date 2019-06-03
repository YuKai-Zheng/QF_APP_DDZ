#include "qf_auto_bindings.hpp"
#include "QNative.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "qf_manual_bindings.hpp"


int lua_qf_auto_bindings_QNative_zny_getCachePath(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_getCachePath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->zny_getCachePath();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_getCachePath",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_getCachePath'.",&tolua_err);
#endif

	return 0;
}

int lua_qf_auto_bindings_QNative_zny_applicationActions(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_applicationActions'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		const char* arg0;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
		if(!ok)
			return 0;
		cobj->zny_applicationActions(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_applicationActions",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_applicationActions'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_getUpdatePath(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_getUpdatePath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->zny_getUpdatePath();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_getUpdatePath",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_getUpdatePath'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_getName(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_getName'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->zny_getName();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_getName",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_getName'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_getCirleImg(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_getCirleImg'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 2) 
	{
		const char* arg0;
		const char* arg1;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

		std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp); arg1 = arg1_tmp.c_str();
		if(!ok)
			return 0;
		cocos2d::Sprite* ret = cobj->zny_getCirleImg(arg0, arg1);
		object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite",(cocos2d::Sprite*)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_getCirleImg",argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_getCirleImg'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_mkdir(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_mkdir'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		const char* arg0;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
		if(!ok)
			return 0;
		cobj->zny_mkdir(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_mkdir",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_mkdir'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_getKey(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_getKey'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->zny_getKey();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_getKey",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_getKey'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_getSignKey(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_getSignKey'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->zny_getSignKey();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_getSignKey",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_getSignKey'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_init(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_init'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		cobj->init();
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "init",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_init'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_rmdir(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_rmdir'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		const char* arg0;

		std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
		if(!ok)
			return 0;
		cobj->zny_rmdir(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_rmdir",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_rmdir'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_zny_setLuaApplicationHanlder(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_zny_setLuaApplicationHanlder'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		int arg0;

		ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0);
		if(!ok)
			return 0;
		cobj->zny_setLuaApplicationHanlder(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "zny_setLuaApplicationHanlder",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_zny_setLuaApplicationHanlder'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_shareInstance(lua_State* tolua_S)
{
	int argc = 0;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S,1,"QNative",0,&tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc == 0)
	{
		if(!ok)
			return 0;
		QNative* ret = QNative::shareInstance();
		object_to_luaval<QNative>(tolua_S, "QNative",(QNative*)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "shareInstance",argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_shareInstance'.",&tolua_err);
#endif
	return 0;
}
int lua_qf_auto_bindings_QNative_constructor(lua_State* tolua_S)
{
	int argc = 0;
	QNative* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif



	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		cobj = new QNative();
		tolua_pushusertype(tolua_S,(void*)cobj,"QNative");
		tolua_register_gc(tolua_S,lua_gettop(tolua_S));
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "QNative",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_constructor'.",&tolua_err);
#endif

	return 0;
}

static int lua_qf_auto_bindings_QNative_finalize(lua_State* tolua_S)
{
	printf("luabindings: finalizing LUA object (QNative)");
#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"QNative",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		QNative* self = (QNative*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
		if (!self) tolua_error(tolua_S,"invalid 'self' in function 'delete'", nullptr);
#endif
		delete self;
	}
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'delete'.",&tolua_err);
	return 0;
#endif
	return 0;
}

int lua_register_qf_auto_bindings_QNative(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"QNative");
	tolua_cclass(tolua_S,"QNative","QNative","cc.Ref",lua_qf_auto_bindings_QNative_finalize);

	tolua_beginmodule(tolua_S,"QNative");
	tolua_function(tolua_S,"new",lua_qf_auto_bindings_QNative_constructor);
	tolua_function(tolua_S,"getCachePath",lua_qf_auto_bindings_QNative_zny_getCachePath);
	tolua_function(tolua_S,"applicationActions",lua_qf_auto_bindings_QNative_zny_applicationActions);
	tolua_function(tolua_S,"getUpdatePath",lua_qf_auto_bindings_QNative_zny_getUpdatePath);
	tolua_function(tolua_S,"getName",lua_qf_auto_bindings_QNative_zny_getName);
	tolua_function(tolua_S,"getCirleImg",lua_qf_auto_bindings_QNative_zny_getCirleImg);
	tolua_function(tolua_S,"mkdir",lua_qf_auto_bindings_QNative_zny_mkdir);
	tolua_function(tolua_S,"rmdir",lua_qf_auto_bindings_QNative_zny_rmdir);
	tolua_function(tolua_S,"getKey",lua_qf_auto_bindings_QNative_zny_getKey);
	tolua_function(tolua_S,"getSignKey",lua_qf_auto_bindings_QNative_getSignKey);
	tolua_function(tolua_S,"init",lua_qf_auto_bindings_QNative_init);
	tolua_function(tolua_S,"setLuaApplicationHanlder",lua_qf_auto_bindings_QNative_zny_setLuaApplicationHanlder);
	tolua_function(tolua_S,"shareInstance", lua_qf_auto_bindings_QNative_shareInstance);
	tolua_function(tolua_S,"registerApplicationActions",lua_qf_manual_bindings_register_application_actions);
	tolua_function(tolua_S,"getScreenBlurSprite", lua_qf_manual_bindings_QNative_zny_getScreenBlurSprite);
    tolua_function(tolua_S,"getScreenGraySprite", lua_qf_manual_bindings_QNative_zny_getScreenGraySprite);
    tolua_function(tolua_S,"getScreenHighlightSprite", lua_qf_manual_bindings_QNative_zny_getScreenHighlightSprite);
	tolua_endmodule(tolua_S);
	std::string typeName = typeid(QNative).name();
	g_luaType[typeName] = "QNative";
	g_typeCast["QNative"] = "QNative";
	return 1;
}
TOLUA_API int register_all_qf_auto_bindings(lua_State* tolua_S)
{
	tolua_open(tolua_S);

	tolua_module(tolua_S,nullptr,0);
	tolua_beginmodule(tolua_S,nullptr);

	lua_register_qf_auto_bindings_QNative(tolua_S);
	lua_register_qf_manual_bindings(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}


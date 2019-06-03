#include "qf_auto_bindings.hpp"
#include "QNative.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "qf_manual_bindings.hpp"


int lua_qf_auto_bindings_QNative_getCachePath(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_getCachePath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->getCachePath();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCachePath",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_getCachePath'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_md5WithBase64(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_md5WithBase64'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2,&arg0);
		if(!ok)
			return 0;
		std::string ret = cobj->md5WithBase64(arg0);
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "md5WithBase64",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_md5WithBase64'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_applicationActions(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_applicationActions'", nullptr);
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
		cobj->applicationActions(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "applicationActions",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_applicationActions'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_getUpdatePath(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_getUpdatePath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->getUpdatePath();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getUpdatePath",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_getUpdatePath'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_getName(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_getName'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->getName();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getName",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_getName'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_getCirleImg(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_getCirleImg'", nullptr);
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
		cocos2d::Sprite* ret = cobj->getCirleImg(arg0, arg1);
		object_to_luaval<cocos2d::Sprite>(tolua_S, "cc.Sprite",(cocos2d::Sprite*)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCirleImg",argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_getCirleImg'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_mkdir(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_mkdir'", nullptr);
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
		cobj->mkdir(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "mkdir",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_mkdir'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_getKey(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_getKey'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
			return 0;
		std::string ret = cobj->getKey();
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getKey",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_getKey'.",&tolua_err);
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
int lua_qf_auto_bindings_QNative_rmdir(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_rmdir'", nullptr);
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
		cobj->rmdir(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "rmdir",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_rmdir'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_setLuaApplicationHanlder(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_setLuaApplicationHanlder'", nullptr);
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
		cobj->setLuaApplicationHanlder(arg0);
		return 0;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setLuaApplicationHanlder",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_setLuaApplicationHanlder'.",&tolua_err);
#endif

	return 0;
}
int lua_qf_auto_bindings_QNative_md5(lua_State* tolua_S)
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
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_qf_auto_bindings_QNative_md5'", nullptr);
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
		std::string ret = cobj->md5(arg0);
		tolua_pushcppstring(tolua_S,ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "md5",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_qf_auto_bindings_QNative_md5'.",&tolua_err);
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
	tolua_function(tolua_S,"getCachePath",lua_qf_auto_bindings_QNative_getCachePath);
	tolua_function(tolua_S,"md5WithBase64",lua_qf_auto_bindings_QNative_md5WithBase64);
	tolua_function(tolua_S,"applicationActions",lua_qf_auto_bindings_QNative_applicationActions);
	tolua_function(tolua_S,"getUpdatePath",lua_qf_auto_bindings_QNative_getUpdatePath);
	tolua_function(tolua_S,"getName",lua_qf_auto_bindings_QNative_getName);
	tolua_function(tolua_S,"getCirleImg",lua_qf_auto_bindings_QNative_getCirleImg);
	tolua_function(tolua_S,"mkdir",lua_qf_auto_bindings_QNative_mkdir);
	tolua_function(tolua_S,"getKey",lua_qf_auto_bindings_QNative_getKey);
	tolua_function(tolua_S,"init",lua_qf_auto_bindings_QNative_init);
	tolua_function(tolua_S,"rmdir",lua_qf_auto_bindings_QNative_rmdir);
	tolua_function(tolua_S,"setLuaApplicationHanlder",lua_qf_auto_bindings_QNative_setLuaApplicationHanlder);
	tolua_function(tolua_S,"md5",lua_qf_auto_bindings_QNative_md5);
	tolua_function(tolua_S,"shareInstance", lua_qf_auto_bindings_QNative_shareInstance);
	tolua_function(tolua_S,"registerApplicationActions",lua_qf_manual_bindings_register_application_actions);
	tolua_function(tolua_S,"getScreenBlurSprite", lua_qf_manual_bindings_QNative_getScreenBlurSprite);
    tolua_function(tolua_S,"getScreenGraySprite", lua_qf_manual_bindings_QNative_getScreenGraySprite);
    tolua_function(tolua_S,"getScreenHighlightSprite", lua_qf_manual_bindings_QNative_getScreenHighlightSprite);
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


#include "lua_ferry_auto.hpp"
#include "ScriptFerry.h"
#include "ScriptBox.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_ferry_IBox_toString(lua_State* tolua_S)
{
    int argc = 0;
    netkit::IBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.IBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::IBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_IBox_toString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->toString();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "toString",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_IBox_toString'.",&tolua_err);
#endif

    return 0;
}
static int lua_ferry_IBox_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (IBox)");
    return 0;
}

int lua_register_ferry_IBox(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"netkit.IBox");
    tolua_cclass(tolua_S,"IBox","netkit.IBox","",nullptr);

    tolua_beginmodule(tolua_S,"IBox");
        tolua_function(tolua_S,"toString",lua_ferry_IBox_toString);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(netkit::IBox).name();
    g_luaType[typeName] = "netkit.IBox";
    g_typeCast["IBox"] = "netkit.IBox";
    return 1;
}

int lua_ferry_BaseFerry_isConnected(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_isConnected'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isConnected();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isConnected",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_isConnected'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_disconnect(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_disconnect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->disconnect();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "disconnect",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_disconnect'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_setSendMsgQueueMaxSize(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_setSendMsgQueueMaxSize'", nullptr);
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
        cobj->setSendMsgQueueMaxSize(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setSendMsgQueueMaxSize",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_setSendMsgQueueMaxSize'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_start(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_start'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->start();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "start",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_start'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_init(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_init'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        std::string arg0;
        int arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        if(!ok)
            return 0;
        int ret = cobj->init(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "init",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_init'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_stop(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_stop'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->stop();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "stop",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_stop'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_update(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_update'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->update();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "update",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_update'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_setConnectTimeout(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_setConnectTimeout'", nullptr);
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
        cobj->setConnectTimeout(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setConnectTimeout",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_setConnectTimeout'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_getLastActiveTime(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_getLastActiveTime'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        long long ret = cobj->getLastActiveTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getLastActiveTime",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_getLastActiveTime'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_setConnectTryInterval(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_setConnectTryInterval'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setConnectTryInterval(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setConnectTryInterval",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_setConnectTryInterval'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_isRunning(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_isRunning'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isRunning();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isRunning",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_isRunning'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_clearEvents(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_clearEvents'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->clearEvents();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "clearEvents",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_clearEvents'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_connect(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::BaseFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_BaseFerry_connect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->connect();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "connect",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_connect'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_BaseFerry_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"ferry.BaseFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        ferry::BaseFerry* ret = ferry::BaseFerry::getInstance();
        object_to_luaval<ferry::BaseFerry>(tolua_S, "ferry.BaseFerry",(ferry::BaseFerry*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_getInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_ferry_BaseFerry_constructor(lua_State* tolua_S)
{
    int argc = 0;
    ferry::BaseFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj = new ferry::BaseFerry();
        tolua_pushusertype(tolua_S,(void*)cobj,"ferry.BaseFerry");
        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "BaseFerry",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_BaseFerry_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_ferry_BaseFerry_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (BaseFerry)");
    return 0;
}

int lua_register_ferry_BaseFerry(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ferry.BaseFerry");
    tolua_cclass(tolua_S,"BaseFerry","ferry.BaseFerry","ferry.Delegate",nullptr);

    tolua_beginmodule(tolua_S,"BaseFerry");
        tolua_function(tolua_S,"new",lua_ferry_BaseFerry_constructor);
        tolua_function(tolua_S,"isConnected",lua_ferry_BaseFerry_isConnected);
        tolua_function(tolua_S,"disconnect",lua_ferry_BaseFerry_disconnect);
        tolua_function(tolua_S,"setSendMsgQueueMaxSize",lua_ferry_BaseFerry_setSendMsgQueueMaxSize);
        tolua_function(tolua_S,"start",lua_ferry_BaseFerry_start);
        tolua_function(tolua_S,"init",lua_ferry_BaseFerry_init);
        tolua_function(tolua_S,"stop",lua_ferry_BaseFerry_stop);
        tolua_function(tolua_S,"update",lua_ferry_BaseFerry_update);
        tolua_function(tolua_S,"setConnectTimeout",lua_ferry_BaseFerry_setConnectTimeout);
        tolua_function(tolua_S,"getLastActiveTime",lua_ferry_BaseFerry_getLastActiveTime);
        tolua_function(tolua_S,"setConnectTryInterval",lua_ferry_BaseFerry_setConnectTryInterval);
        tolua_function(tolua_S,"isRunning",lua_ferry_BaseFerry_isRunning);
        tolua_function(tolua_S,"clearEvents",lua_ferry_BaseFerry_clearEvents);
        tolua_function(tolua_S,"connect",lua_ferry_BaseFerry_connect);
        tolua_function(tolua_S,"getInstance", lua_ferry_BaseFerry_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(ferry::BaseFerry).name();
    g_luaType[typeName] = "ferry.BaseFerry";
    g_typeCast["BaseFerry"] = "ferry.BaseFerry";
    return 1;
}

int lua_ferry_Ferry_pauseSchedule(lua_State* tolua_S)
{
    int argc = 0;
    ferry::Ferry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.Ferry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::Ferry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Ferry_pauseSchedule'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->pauseSchedule();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "pauseSchedule",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Ferry_pauseSchedule'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Ferry_start(lua_State* tolua_S)
{
    int argc = 0;
    ferry::Ferry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.Ferry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::Ferry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Ferry_start'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->start();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "start",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Ferry_start'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Ferry_resumeSchedule(lua_State* tolua_S)
{
    int argc = 0;
    ferry::Ferry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.Ferry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::Ferry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Ferry_resumeSchedule'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->resumeSchedule();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "resumeSchedule",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Ferry_resumeSchedule'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Ferry_stop(lua_State* tolua_S)
{
    int argc = 0;
    ferry::Ferry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.Ferry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::Ferry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Ferry_stop'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->stop();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "stop",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Ferry_stop'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Ferry_isSchedulePaused(lua_State* tolua_S)
{
    int argc = 0;
    ferry::Ferry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.Ferry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::Ferry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Ferry_isSchedulePaused'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isSchedulePaused();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isSchedulePaused",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Ferry_isSchedulePaused'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Ferry_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"ferry.Ferry",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        ferry::Ferry* ret = ferry::Ferry::getInstance();
        object_to_luaval<ferry::Ferry>(tolua_S, "ferry.Ferry",(ferry::Ferry*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Ferry_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_ferry_Ferry_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Ferry)");
    return 0;
}

int lua_register_ferry_Ferry(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ferry.Ferry");
    tolua_cclass(tolua_S,"Ferry","ferry.Ferry","ferry.BaseFerry",nullptr);

    tolua_beginmodule(tolua_S,"Ferry");
        tolua_function(tolua_S,"pauseSchedule",lua_ferry_Ferry_pauseSchedule);
        tolua_function(tolua_S,"start",lua_ferry_Ferry_start);
        tolua_function(tolua_S,"resumeSchedule",lua_ferry_Ferry_resumeSchedule);
        tolua_function(tolua_S,"stop",lua_ferry_Ferry_stop);
        tolua_function(tolua_S,"isSchedulePaused",lua_ferry_Ferry_isSchedulePaused);
        tolua_function(tolua_S,"getInstance", lua_ferry_Ferry_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(ferry::Ferry).name();
    g_luaType[typeName] = "ferry.Ferry";
    g_typeCast["Ferry"] = "ferry.Ferry";
    return 1;
}

int lua_ferry_ScriptEvent_getBox(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptEvent* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptEvent",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptEvent*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptEvent_getBox'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        netkit::IBox* ret = cobj->getBox();
        object_to_luaval<netkit::IBox>(tolua_S, "netkit.IBox",(netkit::IBox*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getBox",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptEvent_getBox'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptEvent_init(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptEvent* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptEvent",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptEvent*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptEvent_init'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->init();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "init",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptEvent_init'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptEvent_getCode(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptEvent* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptEvent",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptEvent*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptEvent_getCode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getCode();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptEvent_getCode'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptEvent_getWhat(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptEvent* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptEvent",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptEvent*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptEvent_getWhat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getWhat();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getWhat",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptEvent_getWhat'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptEvent_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"ferry.ScriptEvent",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        ferry::ScriptEvent* ret = ferry::ScriptEvent::create();
        object_to_luaval<ferry::ScriptEvent>(tolua_S, "ferry.ScriptEvent",(ferry::ScriptEvent*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptEvent_create'.",&tolua_err);
#endif
    return 0;
}
int lua_ferry_ScriptEvent_constructor(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptEvent* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj = new ferry::ScriptEvent();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"ferry.ScriptEvent");
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "ScriptEvent",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptEvent_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_ferry_ScriptEvent_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (ScriptEvent)");
    return 0;
}

int lua_register_ferry_ScriptEvent(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ferry.ScriptEvent");
    tolua_cclass(tolua_S,"ScriptEvent","ferry.ScriptEvent","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"ScriptEvent");
        tolua_function(tolua_S,"new",lua_ferry_ScriptEvent_constructor);
        tolua_function(tolua_S,"getBox",lua_ferry_ScriptEvent_getBox);
        tolua_function(tolua_S,"init",lua_ferry_ScriptEvent_init);
        tolua_function(tolua_S,"getCode",lua_ferry_ScriptEvent_getCode);
        tolua_function(tolua_S,"getWhat",lua_ferry_ScriptEvent_getWhat);
        tolua_function(tolua_S,"create", lua_ferry_ScriptEvent_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(ferry::ScriptEvent).name();
    g_luaType[typeName] = "ferry.ScriptEvent";
    g_typeCast["ScriptEvent"] = "ferry.ScriptEvent";
    return 1;
}

int lua_ferry_ScriptFerry_scriptDelAllEventCallbacks(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelAllEventCallbacks'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->scriptDelAllEventCallbacks();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelAllEventCallbacks",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelAllEventCallbacks'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelAllCallbacks(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelAllCallbacks'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->scriptDelAllCallbacks();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelAllCallbacks",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelAllCallbacks'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_createBox(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_createBox'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        netkit::IBox* ret = cobj->createBox();
        object_to_luaval<netkit::IBox>(tolua_S, "netkit.IBox",(netkit::IBox*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "createBox",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_createBox'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelEventCallback(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelEventCallback'", nullptr);
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
        cobj->scriptDelEventCallback(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelEventCallback",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelEventCallback'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelAllRspCallbacks(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelAllRspCallbacks'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->scriptDelAllRspCallbacks();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelAllRspCallbacks",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelAllRspCallbacks'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelCallbacksForTarget(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelCallbacksForTarget'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Ref* arg0;

        ok &= luaval_to_object<cocos2d::Ref>(tolua_S, 2, "cc.Ref",&arg0);
        if(!ok)
            return 0;
        cobj->scriptDelCallbacksForTarget(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelCallbacksForTarget",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelCallbacksForTarget'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelRspCallback(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelRspCallback'", nullptr);
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
        cobj->scriptDelRspCallback(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelRspCallback",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelRspCallback'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelRspCallbacksForTarget(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelRspCallbacksForTarget'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Ref* arg0;

        ok &= luaval_to_object<cocos2d::Ref>(tolua_S, 2, "cc.Ref",&arg0);
        if(!ok)
            return 0;
        cobj->scriptDelRspCallbacksForTarget(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelRspCallbacksForTarget",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelRspCallbacksForTarget'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_scriptDelEventCallbacksForTarget(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptFerry* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptFerry*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptFerry_scriptDelEventCallbacksForTarget'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Ref* arg0;

        ok &= luaval_to_object<cocos2d::Ref>(tolua_S, 2, "cc.Ref",&arg0);
        if(!ok)
            return 0;
        cobj->scriptDelEventCallbacksForTarget(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "scriptDelEventCallbacksForTarget",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_scriptDelEventCallbacksForTarget'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptFerry_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"ferry.ScriptFerry",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        ferry::ScriptFerry* ret = ferry::ScriptFerry::getInstance();
        object_to_luaval<ferry::ScriptFerry>(tolua_S, "ferry.ScriptFerry",(ferry::ScriptFerry*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptFerry_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_ferry_ScriptFerry_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (ScriptFerry)");
    return 0;
}

int lua_register_ferry_ScriptFerry(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ferry.ScriptFerry");
    tolua_cclass(tolua_S,"ScriptFerry","ferry.ScriptFerry","ferry.Ferry",nullptr);

    tolua_beginmodule(tolua_S,"ScriptFerry");
        tolua_function(tolua_S,"delAllEventCallbacks",lua_ferry_ScriptFerry_scriptDelAllEventCallbacks);
        tolua_function(tolua_S,"delAllCallbacks",lua_ferry_ScriptFerry_scriptDelAllCallbacks);
        tolua_function(tolua_S,"createBox",lua_ferry_ScriptFerry_createBox);
        tolua_function(tolua_S,"delEventCallback",lua_ferry_ScriptFerry_scriptDelEventCallback);
        tolua_function(tolua_S,"delAllRspCallbacks",lua_ferry_ScriptFerry_scriptDelAllRspCallbacks);
        tolua_function(tolua_S,"delCallbacksForTarget",lua_ferry_ScriptFerry_scriptDelCallbacksForTarget);
        tolua_function(tolua_S,"delRspCallback",lua_ferry_ScriptFerry_scriptDelRspCallback);
        tolua_function(tolua_S,"delRspCallbacksForTarget",lua_ferry_ScriptFerry_scriptDelRspCallbacksForTarget);
        tolua_function(tolua_S,"delEventCallbacksForTarget",lua_ferry_ScriptFerry_scriptDelEventCallbacksForTarget);
        tolua_function(tolua_S,"getInstance", lua_ferry_ScriptFerry_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(ferry::ScriptFerry).name();
    g_luaType[typeName] = "ferry.ScriptFerry";
    g_typeCast["ScriptFerry"] = "ferry.ScriptFerry";
    return 1;
}

int lua_ferry_Box_bodyLen(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_bodyLen'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->bodyLen();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "bodyLen",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_bodyLen'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_packetLen(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_packetLen'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->packetLen();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "packetLen",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_packetLen'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_headerLen(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_headerLen'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->headerLen();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "headerLen",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_headerLen'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_toString(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_toString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->toString();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "toString",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_toString'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_unpackDone(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_unpackDone'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->unpackDone();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "unpackDone",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_unpackDone'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_pack(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_pack'", nullptr);
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
        int ret = cobj->pack(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "pack",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_pack'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_unpack(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_unpack'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        const char* arg0;
        int arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        if(!ok)
            return 0;
        int ret = cobj->unpack(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "unpack",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_unpack'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_check(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"netkit.Box",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (netkit::Box*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_Box_check'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        const char* arg0;
        int arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);
        if(!ok)
            return 0;
        int ret = cobj->check(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "check",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_check'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_Box_constructor(lua_State* tolua_S)
{
    int argc = 0;
    netkit::Box* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj = new netkit::Box();
        tolua_pushusertype(tolua_S,(void*)cobj,"netkit.Box");
        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "Box",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_Box_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_ferry_Box_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Box)");
    return 0;
}

int lua_register_ferry_Box(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"netkit.Box");
    tolua_cclass(tolua_S,"Box","netkit.Box","netkit.IBox",nullptr);

    tolua_beginmodule(tolua_S,"Box");
        tolua_function(tolua_S,"new",lua_ferry_Box_constructor);
        tolua_function(tolua_S,"bodyLen",lua_ferry_Box_bodyLen);
        tolua_function(tolua_S,"packetLen",lua_ferry_Box_packetLen);
        tolua_function(tolua_S,"headerLen",lua_ferry_Box_headerLen);
        tolua_function(tolua_S,"toString",lua_ferry_Box_toString);
        tolua_function(tolua_S,"unpackDone",lua_ferry_Box_unpackDone);
        tolua_function(tolua_S,"pack",lua_ferry_Box_pack);
        tolua_function(tolua_S,"unpack",lua_ferry_Box_unpack);
        tolua_function(tolua_S,"check",lua_ferry_Box_check);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(netkit::Box).name();
    g_luaType[typeName] = "netkit.Box";
    g_typeCast["Box"] = "netkit.Box";
    return 1;
}

int lua_ferry_ScriptBox_getCmd(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_getCmd'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getCmd();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCmd",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_getCmd'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_getFlag(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_getFlag'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int32_t ret = cobj->getFlag();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getFlag",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_getFlag'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_setRet(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_setRet'", nullptr);
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
        cobj->setRet(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setRet",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_setRet'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_setCmd(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_setCmd'", nullptr);
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
        cobj->setCmd(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setCmd",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_setCmd'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_getRet(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_getRet'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getRet();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getRet",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_getRet'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_setFlag(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_setFlag'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int32_t arg0;

        ok &= luaval_to_int32(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setFlag(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setFlag",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_setFlag'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_setSn(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_setSn'", nullptr);
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
        cobj->setSn(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setSn",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_setSn'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_getSn(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_getSn'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getSn();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSn",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_getSn'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_getVersion(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_getVersion'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int32_t ret = cobj->getVersion();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVersion",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_getVersion'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_setVersion(lua_State* tolua_S)
{
    int argc = 0;
    ferry::ScriptBox* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (ferry::ScriptBox*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_ferry_ScriptBox_setVersion'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int32_t arg0;

        ok &= luaval_to_int32(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setVersion(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setVersion",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_setVersion'.",&tolua_err);
#endif

    return 0;
}
int lua_ferry_ScriptBox_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"ferry.ScriptBox",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        ferry::ScriptBox* ret = ferry::ScriptBox::create();
        object_to_luaval<ferry::ScriptBox>(tolua_S, "ferry.ScriptBox",(ferry::ScriptBox*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_ferry_ScriptBox_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_ferry_ScriptBox_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (ScriptBox)");
    return 0;
}

int lua_register_ferry_ScriptBox(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ferry.ScriptBox");
    tolua_cclass(tolua_S,"ScriptBox","ferry.ScriptBox","netkit.Box",nullptr);

    tolua_beginmodule(tolua_S,"ScriptBox");
        tolua_function(tolua_S,"getCmd",lua_ferry_ScriptBox_getCmd);
        tolua_function(tolua_S,"getFlag",lua_ferry_ScriptBox_getFlag);
        tolua_function(tolua_S,"setRet",lua_ferry_ScriptBox_setRet);
        tolua_function(tolua_S,"setCmd",lua_ferry_ScriptBox_setCmd);
        tolua_function(tolua_S,"getRet",lua_ferry_ScriptBox_getRet);
        tolua_function(tolua_S,"setFlag",lua_ferry_ScriptBox_setFlag);
        tolua_function(tolua_S,"setSn",lua_ferry_ScriptBox_setSn);
        tolua_function(tolua_S,"getSn",lua_ferry_ScriptBox_getSn);
        tolua_function(tolua_S,"getVersion",lua_ferry_ScriptBox_getVersion);
        tolua_function(tolua_S,"setVersion",lua_ferry_ScriptBox_setVersion);
        tolua_function(tolua_S,"create", lua_ferry_ScriptBox_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(ferry::ScriptBox).name();
    g_luaType[typeName] = "ferry.ScriptBox";
    g_typeCast["ScriptBox"] = "ferry.ScriptBox";
    return 1;
}
TOLUA_API int register_all_ferry(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"ferry",0);
	tolua_beginmodule(tolua_S,"ferry");

	lua_register_ferry_BaseFerry(tolua_S);
	lua_register_ferry_ScriptEvent(tolua_S);
	lua_register_ferry_IBox(tolua_S);
	lua_register_ferry_Box(tolua_S);
	lua_register_ferry_Ferry(tolua_S);
	lua_register_ferry_ScriptFerry(tolua_S);
	lua_register_ferry_ScriptBox(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}


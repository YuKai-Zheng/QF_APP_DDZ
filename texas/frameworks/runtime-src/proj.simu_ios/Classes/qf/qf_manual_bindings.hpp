#include "base/ccConfig.h"
#ifndef __qf_manual_bindings_h__
#define __qf_manual_bindings_h__

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int lua_qf_manual_bindings_register_application_actions(lua_State* tolua_S);

int lua_qf_manual_bindings_QNative_getScreenBlurSprite(lua_State* tolua_S);

int lua_qf_manual_bindings_QNative_getScreenGraySprite(lua_State* tolua_S);

int lua_qf_manual_bindings_QNative_getScreenHighlightSprite(lua_State* tolua_S);

void lua_register_qf_manual_bindings(lua_State* tolua_S);


#endif // __qf_manual_bindings_h__

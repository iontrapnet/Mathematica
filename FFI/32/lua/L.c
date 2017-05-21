#include <stdlib.h>
#include "lua.h"   
#include "lauxlib.h"   
#include "lualib.h"  

static int Lfunc(lua_State* L) { 
    lua_pushinteger(L, (int)L);
    return 0;   
}
static const struct luaL_Reg Llib[] = {
    {"L",Lfunc},  
    {NULL,NULL}  
};  
LUALIB_API int luaopen_L(lua_State *L) {
    luaL_register(L,"L",Llib);   
    return 0;
}
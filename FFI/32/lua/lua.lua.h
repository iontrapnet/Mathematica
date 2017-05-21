typedef char *va_list;
typedef va_list __gnuc_va_list;
typedef unsigned int size_t;
typedef unsigned short wchar_t;
typedef int ptrdiff_t;
typedef char int8_t;
typedef short int int16_t;
typedef int int32_t;
typedef long long int int64_t;
void *alloca(size_t);
typedef unsigned int wint_t;
typedef struct lua_State lua_State;
typedef int (*lua_CFunction) (lua_State *L);
typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);
typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);
typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);
typedef double lua_Number;
typedef ptrdiff_t lua_Integer;
extern lua_State *(lua_newstate) (lua_Alloc f, void *ud);
extern void       (lua_close) (lua_State *L);
extern lua_State *(lua_newthread) (lua_State *L);
extern lua_CFunction (lua_atpanic) (lua_State *L, lua_CFunction panicf);
extern int   (lua_gettop) (lua_State *L);
extern void  (lua_settop) (lua_State *L, int idx);
extern void  (lua_pushvalue) (lua_State *L, int idx);
extern void  (lua_remove) (lua_State *L, int idx);
extern void  (lua_insert) (lua_State *L, int idx);
extern void  (lua_replace) (lua_State *L, int idx);
extern int   (lua_checkstack) (lua_State *L, int sz);
extern void  (lua_xmove) (lua_State *from, lua_State *to, int n);
extern int             (lua_isnumber) (lua_State *L, int idx);
extern int             (lua_isstring) (lua_State *L, int idx);
extern int             (lua_iscfunction) (lua_State *L, int idx);
extern int             (lua_isuserdata) (lua_State *L, int idx);
extern int             (lua_type) (lua_State *L, int idx);
extern const char     *(lua_typename) (lua_State *L, int tp);
extern int            (lua_equal) (lua_State *L, int idx1, int idx2);
extern int            (lua_rawequal) (lua_State *L, int idx1, int idx2);
extern int            (lua_lessthan) (lua_State *L, int idx1, int idx2);
extern lua_Number      (lua_tonumber) (lua_State *L, int idx);
extern lua_Integer     (lua_tointeger) (lua_State *L, int idx);
extern int             (lua_toboolean) (lua_State *L, int idx);
extern const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
extern size_t          (lua_objlen) (lua_State *L, int idx);
extern lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
extern void	       *(lua_touserdata) (lua_State *L, int idx);
extern lua_State      *(lua_tothread) (lua_State *L, int idx);
extern const void     *(lua_topointer) (lua_State *L, int idx);
extern void  (lua_pushnil) (lua_State *L);
extern void  (lua_pushnumber) (lua_State *L, lua_Number n);
extern void  (lua_pushinteger) (lua_State *L, lua_Integer n);
extern void  (lua_pushlstring) (lua_State *L, const char *s, size_t l);
extern void  (lua_pushstring) (lua_State *L, const char *s);
extern const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
extern const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
extern void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
extern void  (lua_pushboolean) (lua_State *L, int b);
extern void  (lua_pushlightuserdata) (lua_State *L, void *p);
extern int   (lua_pushthread) (lua_State *L);
extern void  (lua_gettable) (lua_State *L, int idx);
extern void  (lua_getfield) (lua_State *L, int idx, const char *k);
extern void  (lua_rawget) (lua_State *L, int idx);
extern void  (lua_rawgeti) (lua_State *L, int idx, int n);
extern void  (lua_createtable) (lua_State *L, int narr, int nrec);
extern void *(lua_newuserdata) (lua_State *L, size_t sz);
extern int   (lua_getmetatable) (lua_State *L, int objindex);
extern void  (lua_getfenv) (lua_State *L, int idx);
extern void  (lua_settable) (lua_State *L, int idx);
extern void  (lua_setfield) (lua_State *L, int idx, const char *k);
extern void  (lua_rawset) (lua_State *L, int idx);
extern void  (lua_rawseti) (lua_State *L, int idx, int n);
extern int   (lua_setmetatable) (lua_State *L, int objindex);
extern int   (lua_setfenv) (lua_State *L, int idx);
extern void  (lua_call) (lua_State *L, int nargs, int nresults);
extern int   (lua_pcall) (lua_State *L, int nargs, int nresults, int errfunc);
extern int   (lua_cpcall) (lua_State *L, lua_CFunction func, void *ud);
extern int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
                                        const char *chunkname);
extern int (lua_dump) (lua_State *L, lua_Writer writer, void *data);
extern int  (lua_yield) (lua_State *L, int nresults);
extern int  (lua_resume) (lua_State *L, int narg);
extern int  (lua_status) (lua_State *L);
extern int (lua_gc) (lua_State *L, int what, int data);
extern int   (lua_error) (lua_State *L);
extern int   (lua_next) (lua_State *L, int idx);
extern void  (lua_concat) (lua_State *L, int n);
extern lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
extern void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);
extern void lua_setlevel	(lua_State *from, lua_State *to);
typedef struct lua_Debug lua_Debug;  
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);
extern int lua_getstack (lua_State *L, int level, lua_Debug *ar);
extern int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
extern const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
extern const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
extern const char *lua_getupvalue (lua_State *L, int funcindex, int n);
extern const char *lua_setupvalue (lua_State *L, int funcindex, int n);
extern int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
extern lua_Hook lua_gethook (lua_State *L);
extern int lua_gethookmask (lua_State *L);
extern int lua_gethookcount (lua_State *L);
extern void *lua_upvalueid (lua_State *L, int idx, int n);
extern void lua_upvaluejoin (lua_State *L, int idx1, int n1, int idx2, int n2);
extern int lua_loadx (lua_State *L, lua_Reader reader, void *dt,
		       const char *chunkname, const char *mode);
struct lua_Debug {
  int event;
  const char *name;	
  const char *namewhat;	
  const char *what;	
  const char *source;	
  int currentline;	
  int nups;		
  int linedefined;	
  int lastlinedefined;	
  char short_src[60]; 
  
  int i_ci;  
};

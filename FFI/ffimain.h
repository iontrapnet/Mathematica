
#include "mathlink.h"
#include <windows.h>

#ifdef __cplusplus
#define EXTERNC extern "C" 
#else
#define EXTERNC extern 
#endif

#ifdef FFI_EXPORTS
#define DLL __declspec(dllexport) 
#else
#define DLL __declspec(dllimport) 
#endif
#define API EXTERNC DLL

API HWND FFIInitializeIcon( HINSTANCE hInstance, int nCmdShow);
#if MLINTERFACE >= 3
API int FFIMain( int argc, char **argv);
#else
API int FFIMain( int argc, charpp_ct argv);
#endif /* MLINTERFACE >= 3 */

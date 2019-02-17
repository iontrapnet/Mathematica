#include <mathlink.h>

#ifndef EXTERNC
#ifdef __cplusplus
#define EXTERNC extern "C" 
#else
#define EXTERNC extern 
#endif
#endif

#ifdef _WIN32
#ifdef FFI_EXPORTS
#define DLL __declspec(dllexport) 
#else
#define DLL __declspec(dllimport) 
#endif
#else
#define DLL
#endif

#define API EXTERNC DLL

#ifdef _WIN32
#include <windows.h>
API HWND FFIInitializeIcon( HINSTANCE hInstance, int nCmdShow);
#endif
#if MLINTERFACE >= 3
API int FFIMain( int argc, char **argv);
#else
API int FFIMain( int argc, charpp_ct argv);
#endif /* MLINTERFACE >= 3 */

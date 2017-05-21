// #define WIN32_LEAN_AND_MEAN
// #include <windows.h>

#define __declspec(x) __attribute__((x))
#define DLL_EXPORT __declspec(dllexport)

DLL_EXPORT int test() { return 100; }
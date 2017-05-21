// tcc -shared newt.c
// icl /Ox /LD newt.c /Fenewt.dll
#include <windows.h>

#define DLL_EXPORT __declspec(dllexport)

DLL_EXPORT double newt(double x, int n) {
    double t = x;
    int i;
    for (i = 0; i < n; ++i) {
        t = 0.5 * (t + x / t);
    }
    return t;
}
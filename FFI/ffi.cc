#include "mathlink.h"
#include "WolframLibrary.h"
#include <string.h>
#include <dyncall.h>
#include <dynload.h>

#ifdef __cplusplus
extern "C" {
#endif 

#include <dyncall_callf.h>
#include <dyncall_callback.h>

#ifdef __cplusplus
}
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

#ifdef UNIX_MATHLINK
#define DLL
#else 
#define DLL __declspec(dllexport) 
#endif
#define API EXTERNC DLL

#ifdef _WIN64
#define ptr_t int64
#define MLGetPtr MLGetInteger64
#define MLPutPtr MLPutInteger64
#else
#define ptr_t int32
#define MLGetPtr MLGetInteger32
#define MLPutPtr MLPutInteger32
#endif

typedef unsigned char byte;
typedef __int32 int32;
typedef __int64 int64;
typedef float real32;
typedef double real64;

API ptr_t FFI_Open(size_t size) {
    return (ptr_t)dcNewCallVM(size);
}

API void FFI_Mode(ptr_t vm, int mode) {
    dcMode((DCCallVM*)vm, mode);
}

API void FFI_Close(ptr_t vm) {
    dcFree((DCCallVM*)vm);
}

API void FFI_Reset(ptr_t vm) {
    dcReset((DCCallVM*)vm);
}

EXTERNC ptr_t FFI_Init(size_t size, int mode) {
    ptr_t vm = FFI_Open(size);
    FFI_Mode(vm, mode);
    return vm;
}

static void _FFI_Exit(ptr_t vm) {
    FFI_Close(vm);
}

EXTERNC void FFI_Exit(ptr_t vm) {
    _FFI_Exit(vm);
    MLPutSymbol(stdlink, "Null");
}

#define FFI_SIZE_DECODE(bytes)\
	const byte* ptr = (byte*)bytes;\
    int bytesize = ((*ptr) >> 6) + 1;\
    int size = 0;\
    for (int i = 0; i < bytesize - 1; ++i)\
        ((byte*)&size)[i] = ptr[bytesize - 1 - i];\
    ((byte*)&size)[bytesize - 1] = ptr[0] & 63;\
    ptr += bytesize;\
    bytesize = (int)(size / 4) + (size % 4 == 0 ? 0 : 1);
            
#define FFI_SIG_DECODE_BEGIN()\
    int i = 0, j = 0;\
    int mask[4] = {192, 48, 12, 3}, shift[4] = {6, 4, 2, 0}, last[4] = {3, 0, 1, 2};\
    for (i = 0; i < bytesize; ++i) {\
        for (j = 0; j < 4; ++j) {\
            if (i == bytesize - 1 && j == last[size % 4])\
                break;\
            switch ((ptr[i] & mask[j]) >> shift[j]) {\

#define FFI_SIG_DECODE_END()\
            }\
        }\
    }\
    
#define FFI_TYPE_DECODE()\
    int type = (ptr[bytesize - 1] & mask[j]) >> shift[j];\

API void FFI_PutInteger32(ptr_t vm, int32 arg) {
    dcArgInt((DCCallVM*)vm, arg);
}

API void FFI_PutInteger64(ptr_t vm, int64 arg) {
    dcArgLongLong((DCCallVM*)vm, arg);
}

API void FFI_PutReal32(ptr_t vm, real32 arg) {
    dcArgFloat((DCCallVM*)vm, arg);
}

API void FFI_PutReal64(ptr_t vm, real64 arg) {
    dcArgDouble((DCCallVM*)vm, arg);
}
    
API int32 FFI_GetInteger32(ptr_t vm, void* addr) {
    return (int32)dcCallInt((DCCallVM*)vm, addr);
}

API int64 FFI_GetInteger64(ptr_t vm, void* addr) {
    return (int64)dcCallLongLong((DCCallVM*)vm, addr);
}

API real32 FFI_GetReal32(ptr_t vm, void* addr) {
    return (real32)dcCallFloat((DCCallVM*)vm, addr);
}

API real64 FFI_GetReal64(ptr_t vm, void* addr) {
    return (real64)dcCallDouble((DCCallVM*)vm, addr);
}

API void FFI_VApply(ptr_t vm, void* result, void* addr, const char* signature, va_list args) {
    dcVCallF((DCCallVM*)vm, (DCValue*)result, addr, signature, args);
}

API void FFI_Apply(ptr_t vm, void* result, void* addr, const char* signature, ...) {
    va_list args;
    va_start(args, signature);
    FFI_VApply(vm, result, addr, signature, args);
    va_end(args);
}

static void _FFI_Call(ptr_t vm, const byte* bytes, int len, MLINK mlp) {
    FFI_Reset(vm);
    FFI_SIZE_DECODE(bytes + sizeof(ptr_t))
    long argc;
    MLCheckFunction(mlp, "List", &argc);
    if (argc != size - 1) {
        MLNewPacket(mlp);
        MLPutSymbol(mlp, "$Failed");
        return;
    }
    FFI_SIG_DECODE_BEGIN()
                case 0: { int32 r; MLGetInteger32(mlp, &r); FFI_PutInteger32(vm, *(int32*)&r); } break;
                case 1: { int64 r; MLGetInteger64(mlp, &r); FFI_PutInteger64(vm, *(int64*)&r); } break;
                case 2: { real32 r; MLGetReal32(mlp, &r); FFI_PutReal32(vm, *(real32*)&r); } break;
                case 3: { real64 r; MLGetReal64(mlp, &r); FFI_PutReal64(vm, *(real64*)&r); } break;
    FFI_SIG_DECODE_END()
    FFI_TYPE_DECODE()
    void* addr = (void*)*(ptr_t*)bytes;
    switch (type) {
        case 0: MLPutInteger32(mlp, FFI_GetInteger32(vm, addr)); break;
        case 1: {int64 r = FFI_GetInteger64(vm, addr); MLPutInteger64(mlp, *(int64*)&r);} break;
        case 2: MLPutReal32(mlp, FFI_GetReal32(vm, addr)); break;
        case 3: MLPutReal64(mlp, FFI_GetReal64(vm, addr)); break;
    }
}

EXTERNC void FFI_Call(ptr_t vm, const byte* bytes, int len) {
    _FFI_Call(vm, bytes, len, stdlink);
}

API ptr_t FFI_Load(const char* path) {
    return (ptr_t)dlLoadLibrary(path);
}

API void FFI_Free(ptr_t handle) {
    dlFreeLibrary((DLLib*)handle);
}

static void _FFI_Unload(ptr_t handle) {
    FFI_Free(handle);
}

EXTERNC void FFI_Unload(ptr_t handle) {
    _FFI_Unload(handle);
    MLPutSymbol(stdlink, "Null");
}

API ptr_t FFI_Find(ptr_t handle, const char* symbol) {
    return (ptr_t)dlFindSymbol((DLLib*)handle, symbol);
}

EXTERNC ptr_t FFI_NewData(const byte* data, int len) {
    byte* r = new byte[len];
    memcpy(r, data, len);
    return (ptr_t)r;
}

static void _FFI_ReleaseData(ptr_t ptr) {
    delete [] (byte*)ptr;
}

EXTERNC void FFI_ReleaseData(ptr_t ptr) {
    _FFI_ReleaseData(ptr);
    MLPutSymbol(stdlink, "Null");
}

EXTERNC void FFI_ReadData(ptr_t ptr, int len) {
    MLPutByteString(stdlink, (byte*)ptr, len);
}

static void _FFI_WriteData(ptr_t ptr, const byte* data, int len) {
    memcpy((byte*)ptr, data, len);
}

EXTERNC void FFI_WriteData(ptr_t ptr, const byte* data, int len) {
    _FFI_WriteData(ptr, data, len);
    MLPutSymbol(stdlink, "Null");
}

static char FFI_DefaultClosureHandler(DCCallback* pcb, DCArgs* args, DCValue* result, byte* userdata) {
    MLINK kernel = *(MLINK*)userdata;
    MLActivate(kernel);
	MLPutFunction(kernel, "EvaluatePacket", 1);
	MLPutFunction(kernel, "FFI`DefaultClosureHandler", 2);
    MLPutPtr(kernel, (ptr_t)pcb);
    FFI_SIZE_DECODE(userdata + sizeof(ptr_t))
	MLPutFunction(kernel, "List", size - 1);
    FFI_SIG_DECODE_BEGIN()
        case 0: MLPutInteger32(kernel, dcbArgInt(args)); break;
        case 1: {int64 r = dcbArgLongLong(args); MLPutInteger64(kernel, *(int64*)r);} break;
        case 2: MLPutReal32(kernel, dcbArgFloat(args)); break;
        case 3: MLPutReal64(kernel, dcbArgDouble(args)); break;
    FFI_SIG_DECODE_END()
    MLEndPacket(kernel);
    MLFlush(kernel);
    /*for (ptr_t t = 0; t < 10 && !MLAbort && !MLReady(kernel); ++t)
        Sleep(1 << t);
    if (!MLReady(kernel))
        return 0;*/
    ptr_t pkt;
    while ((pkt = MLAnswer(kernel)) && pkt != RETURNPKT)
        MLNewPacket(kernel);
    if (pkt != RETURNPKT)
        return 0;
    FFI_TYPE_DECODE()
    switch (type) {
        case 0: MLGetInteger32(kernel, (int32*)result); break;
        case 1: MLGetInteger64(kernel, (int64*)result); break;
        case 2: MLGetReal32(kernel, (real32*)result); break;
        case 3: MLGetReal64(kernel, (real64*)result); break;
    }
    MLNewPacket(kernel);
	return 0;
}

static DCCallback* _FFI_NewClosure(byte* userdata, DCCallbackHandler* funcptr) {
	FFI_SIZE_DECODE(userdata + sizeof(ptr_t))
	char *signature = new char[size + 2], *strptr = signature;
	FFI_SIG_DECODE_BEGIN()
        case 0: *strptr++ = 'i'; break;
        case 1: *strptr++ = 'l'; break;
        case 2: *strptr++ = 'f'; break;
        case 3: *strptr++ = 'd'; break;
    FFI_SIG_DECODE_END()    
    *strptr++ = ')';
	FFI_TYPE_DECODE()
	switch (type) {
        case 0: *strptr++ = 'i'; break;
        case 1: *strptr++ = 'l'; break;
        case 2: *strptr++ = 'f'; break;
        case 3: *strptr++ = 'd'; break;
	}
	*strptr = '\0';
	DCCallback* cb = dcbNewCallback(signature, funcptr, userdata);
    delete [] signature;
    return cb;
}

static MLENV auxenv = 0;
static MLINK auxlink = 0;
static void hexstr(int x, char* ptr) {
    static const char digit[] = "0123456789abcdef";
    int mask = 0xF;
    for (int i = 0; i < 8; ++i, x >>= 4)
        *--ptr = digit[x & mask];
}
static void initaux() {
    if (!auxenv)
        auxenv = MLInitialize(0);
    if (!auxlink) {
        //char command[] = " -mathlink -linkprotocol \"\" -linkconnect -linkname \"FFI_xxxxxxxx\"";
        //char *ptr = command + sizeof(command) / sizeof(char) - 2;
        //hexstr(userdata, ptr);
        static char command[] = " -mathlink -linkprotocol \"\" -linkconnect -linkname \"FFI_aux\"";
        int error = 0;
        auxlink = MLOpenString(auxenv, command, &error);
        if(auxlink == (MLINK)0 || error != MLEOK) {
            MLAlert(auxenv, MLErrorString(auxenv, error));
            return;
        }
        MLSetYieldFunction(auxlink, stdyielder);
        MLSetMessageHandler(auxlink, stdhandler);
    }
}
static void exitaux() {
    MLClose(auxlink);
    MLDeinitialize(auxenv);
}
EXTERNC ptr_t FFI_NewClosure(ptr_t userdata, ptr_t funcptr) {
    //initaux();
    if (!*(MLINK*)userdata)
        *(MLINK*)userdata = stdlink;//auxlink;
	if (funcptr == 0)
        funcptr = (ptr_t)FFI_DefaultClosureHandler;
    return (ptr_t)_FFI_NewClosure((byte*)userdata, (DCCallbackHandler*)funcptr);
}

static void _FFI_ReleaseClosure(ptr_t ptr) {
	dcbFreeCallback((DCCallback*)ptr);
}

EXTERNC void FFI_ReleaseClosure(ptr_t ptr) {
    //DCCallback* cb = (DCCallback*)ptr;
    //MLINK kernel = *(ptr_t*)cb->userdata;
    //MLClose(kernel);
    if (ptr)
        _FFI_ReleaseClosure(ptr);
    else {
        //exitaux();
    }
	MLPutSymbol(stdlink, "Null");
}

EXTERNC ptr_t FFI_ID() {
    return (ptr_t)stdlink;
}

API mint WolframLibrary_getVersion( ) {
	return WolframLibraryVersion;
}

API int WolframLibrary_initialize( WolframLibraryData libData) {
	return 0;
}

API int FFI_$Init(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
    MArgument_setInteger(Res, 
    FFI_Init((size_t)MArgument_getInteger(Args[0]), (int)MArgument_getInteger(Args[1])));
    return LIBRARY_NO_ERROR;
}

API int FFI_$Exit(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
    _FFI_Exit(MArgument_getInteger(Args[0]));
    return LIBRARY_NO_ERROR;
}

API int FFI_$Call(WolframLibraryData libData,
			MLINK mlp) {
    long argc = 0;
    MLCheckFunction(mlp, "List", &argc);
    if (argc < 2)
        return LIBRARY_FUNCTION_ERROR;
    ptr_t vm = 0;
    MLGetPtr(mlp, &vm);
    const byte* bytes = NULL;
    int len = 0;
    MLGetByteString(mlp, &bytes, &len, 0);
    _FFI_Call(vm, bytes, len, mlp);
    MLReleaseByteString(mlp, bytes, len);
    return LIBRARY_NO_ERROR;
}

API int FFI_$Load(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
    char* path = MArgument_getUTF8String(Args[0]);
    MArgument_setInteger(Res, FFI_Load(path));
    libData->UTF8String_disown(path);
    return LIBRARY_NO_ERROR;
}

API int FFI_$Unload(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
    _FFI_Unload(MArgument_getInteger(Args[0]));
    return LIBRARY_NO_ERROR;
}

API int FFI_$Find(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
    char* symbol = MArgument_getUTF8String(Args[1]);
    MArgument_setInteger(Res, FFI_Find(MArgument_getInteger(Args[0]), symbol));
    libData->UTF8String_disown(symbol);
    return LIBRARY_NO_ERROR;
}

API int FFI_$NewData(WolframLibraryData libData,
			MLINK mlp) {
	long argc = 0;
    MLCheckFunction(mlp, "List", &argc);
    if (argc != 1)
        return LIBRARY_FUNCTION_ERROR;
    const byte* data = NULL;
    int len = 0;
    MLGetByteString(mlp, &data, &len, 0);
    MLPutPtr(mlp, FFI_NewData(data, len));
    MLReleaseByteString(mlp, data, len);
    return LIBRARY_NO_ERROR;
}

API int FFI_$ReleaseData(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
    _FFI_ReleaseData(MArgument_getInteger(Args[0]));
    return LIBRARY_NO_ERROR;
}

API int FFI_$ReadData(WolframLibraryData libData,
			MLINK mlp) {
	long argc = 0;
    MLCheckFunction(mlp, "List", &argc);
    if (argc != 2)
        return LIBRARY_FUNCTION_ERROR;
    ptr_t ptr = 0;
    int len = 0;
    MLGetPtr(mlp, &ptr);
    MLGetInteger(mlp, &len);
    MLPutByteString(mlp, (byte*)ptr, len);
    return LIBRARY_NO_ERROR;
}

API int FFI_$WriteData(WolframLibraryData libData,
			MLINK mlp) {
	long argc = 0;
    MLCheckFunction(mlp, "List", &argc);
    if (argc != 2)
        return LIBRARY_FUNCTION_ERROR;
    ptr_t ptr = 0;
    MLGetPtr(mlp, &ptr);
    const byte* data = NULL;
    int len = 0;
    MLGetByteString(mlp, &data, &len, 0);
    _FFI_WriteData(ptr, data, len);
    MLReleaseByteString(mlp, data, len);
    return LIBRARY_NO_ERROR;
}

static char FFI_$DefaultClosureHandler(DCCallback* pcb, DCArgs* args, DCValue* result, byte* userdata) {
    WolframLibraryData libData = *(WolframLibraryData*)userdata;
    MLINK kernel = libData->getMathLink(libData);
	MLPutFunction(kernel, "EvaluatePacket", 1);
	MLPutFunction(kernel, "FFI`$DefaultClosureHandler", 2);
	MLPutPtr(kernel, (ptr_t)pcb);
    FFI_SIZE_DECODE(userdata + sizeof(ptr_t))
	MLPutFunction(kernel, "List", size - 1);
    FFI_SIG_DECODE_BEGIN()
        case 0: MLPutInteger32(kernel, dcbArgInt(args)); break;
        case 1: {int64 r = dcbArgLongLong(args); MLPutInteger64(kernel, *(int64*)r);} break;
        case 2: MLPutReal32(kernel, dcbArgFloat(args)); break;
        case 3: MLPutReal64(kernel, dcbArgDouble(args)); break;
    FFI_SIG_DECODE_END()
	libData->processMathLink(kernel);
    if (MLNextPacket(kernel) != RETURNPKT)
        return 0;
    FFI_TYPE_DECODE()
    switch (type) {
        case 0: MLGetInteger32(kernel, (int32*)result); break;
        case 1: MLGetInteger64(kernel, (int64*)result); break;
        case 2: MLGetReal32(kernel, (real32*)result); break;
        case 3: MLGetReal64(kernel, (real64*)result); break;
    }
    MLNewPacket(kernel);
	return 0;
}

API int FFI_$NewClosure(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
	byte* userdata = (byte*)MArgument_getInteger(Args[0]);
	if (!*(ptr_t*)userdata)
        *(ptr_t*)userdata = (ptr_t)libData;
	DCCallbackHandler* funcptr = (DCCallbackHandler*)MArgument_getInteger(Args[1]);
	if (funcptr == 0)
        funcptr = (DCCallbackHandler*)FFI_$DefaultClosureHandler;
    MArgument_setInteger(Res, (ptr_t)_FFI_NewClosure(userdata, funcptr));
    return LIBRARY_NO_ERROR;
}

API int FFI_$ReleaseClosure(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
	_FFI_ReleaseClosure(MArgument_getInteger(Args[0]));
    return LIBRARY_NO_ERROR;
}

API int FFI_$ID(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
	MArgument_setInteger(Res, (ptr_t)libData);
	return LIBRARY_NO_ERROR;
}

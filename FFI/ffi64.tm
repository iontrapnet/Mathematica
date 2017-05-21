#include <stddef.h>

#ifdef _WIN64
#define ptr_t int64
#else
#define ptr_t int32
#endif

typedef unsigned char byte;
typedef __int32 int32;
typedef __int64 int64;

#ifdef __cplusplus
#define EXTERNC extern "C" 
#else
#define EXTERNC extern
#endif

EXTERNC ptr_t FFI_Init P(( size_t, int ));

:Begin:
:Function:       FFI_Init
:Pattern:        FFI`Init[size_Integer, mode_Integer]
:Arguments:      { size, mode }
:ArgumentTypes:  { Integer64, Integer }
:ReturnType:     Integer64
:End:

EXTERNC void FFI_Exit P(( ptr_t ));

:Begin:
:Function:       FFI_Exit
:Pattern:        FFI`Exit[vm_Integer]
:Arguments:      { vm }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

EXTERNC void FFI_Call P(( ptr_t, const byte*, int ));

:Begin:
:Function:       FFI_Call
:Pattern:        FFI`Call[vm_Integer, call_String, args:{___?NumberQ}]
:Arguments:      { vm, call, args }
:ArgumentTypes:  { Integer64, ByteString, Manual }
:ReturnType:     Manual
:End:

EXTERNC ptr_t FFI_Load P(( const char* ));

:Begin:
:Function:       FFI_Load
:Pattern:        FFI`Load[path_String]
:Arguments:      { path }
:ArgumentTypes:  { String }
:ReturnType:     Integer64
:End:

EXTERNC void FFI_Unload P(( ptr_t ));

:Begin:
:Function:       FFI_Unload
:Pattern:        FFI`Unload[handle_Integer]
:Arguments:      { handle }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

EXTERNC ptr_t FFI_Find P(( ptr_t, const char* ));

:Begin:
:Function:       FFI_Find
:Pattern:        FFI`Find[handle_Integer, symbol_String]
:Arguments:      { handle, symbol }
:ArgumentTypes:  { Integer64, String }
:ReturnType:     Integer64
:End:

EXTERNC ptr_t FFI_NewData P(( const byte*, int ));

:Begin:
:Function:       FFI_NewData
:Pattern:        FFI`NewData[data_String]
:Arguments:      { data }
:ArgumentTypes:  { ByteString }
:ReturnType:     Integer64
:End:

EXTERNC void FFI_ReleaseData P(( ptr_t ));

:Begin:
:Function:       FFI_ReleaseData
:Pattern:        FFI`ReleaseData[ptr_Integer]
:Arguments:      { ptr }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

EXTERNC void FFI_ReadData P(( ptr_t, int ));

:Begin:
:Function:       FFI_ReadData
:Pattern:        FFI`ReadData[ptr_Integer, len_Integer]
:Arguments:      { ptr, len }
:ArgumentTypes:  { Integer64, Integer }
:ReturnType:     Manual
:End:

EXTERNC void FFI_WriteData P(( ptr_t, const byte*, int ));

:Begin:
:Function:       FFI_WriteData
:Pattern:        FFI`WriteData[ptr_Integer, data_String]
:Arguments:      { ptr, data }
:ArgumentTypes:  { Integer64, ByteString }
:ReturnType:     Manual
:End:

EXTERNC ptr_t FFI_NewClosure P(( ptr_t, ptr_t ));

:Begin:
:Function:       FFI_NewClosure
:Pattern:        FFI`NewClosure[userdata_Integer, funcptr_Integer:0]
:Arguments:      { userdata, funcptr }
:ArgumentTypes:  { Integer64, LongInteger }
:ReturnType:     Integer64
:End:

EXTERNC void FFI_ReleaseClosure P(( ptr_t ));

:Begin:
:Function:       FFI_ReleaseClosure
:Pattern:        FFI`ReleaseClosure[ptr_Integer]
:Arguments:      { ptr }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

EXTERNC ptr_t FFI_ID P(());

:Begin:
:Function:       FFI_ID
:Pattern:        FFI`ID[]
:Arguments:      {}
:ArgumentTypes:  {}
:ReturnType:     Integer64
:End:

#define FFI_EXPORTS
#include "ffimain.h"

#ifndef UNIX_MATHLINK
API HWND FFIInitializeIcon( HINSTANCE hInstance, int nCmdShow) {
    return MLInitializeIcon(hInstance, nCmdShow);
}
#endif

#if MLINTERFACE >= 3
API int FFIMain( int argc, char **argv)
#else
API int FFIMain( int argc, charpp_ct argv)
#endif /* MLINTERFACE >= 3 */
{
#if MLINTERFACE >= 3
 	return MLMain( argc, argv);
#else
 	return MLMain( argc, argv);
#endif /* MLINTERFACE >= 3 */
}
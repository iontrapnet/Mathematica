typedef unsigned char byte;
typedef __int32 int32;
typedef __int64 int64;

extern int64 FFI_Init P(( int64, int ));

:Begin:
:Function:       FFI_Init
:Pattern:        FFI`Init[64][size_Integer, mode_Integer]
:Arguments:      { size, mode }
:ArgumentTypes:  { Integer64, Integer }
:ReturnType:     Integer64
:End:

extern void FFI_Exit P(( int64 ));

:Begin:
:Function:       FFI_Exit
:Pattern:        FFI`Exit[64][vm_Integer]
:Arguments:      { vm }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

extern void FFI_Call P(( int64, const byte*, int ));

:Begin:
:Function:       FFI_Call
:Pattern:        FFI`Call[64][vm_Integer, call_String, args:{___?NumberQ}]
:Arguments:      { vm, call, args }
:ArgumentTypes:  { Integer64, ByteString, Manual }
:ReturnType:     Manual
:End:

extern int64 FFI_Load P(( const char* ));

:Begin:
:Function:       FFI_Load
:Pattern:        FFI`Load[64][path_String]
:Arguments:      { path }
:ArgumentTypes:  { String }
:ReturnType:     Integer64
:End:

extern void FFI_Unload P(( int64 ));

:Begin:
:Function:       FFI_Unload
:Pattern:        FFI`Unload[64][handle_Integer]
:Arguments:      { handle }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

extern int64 FFI_Find P(( int64, const char* ));

:Begin:
:Function:       FFI_Find
:Pattern:        FFI`Find[64][handle_Integer, symbol_String]
:Arguments:      { handle, symbol }
:ArgumentTypes:  { Integer64, String }
:ReturnType:     Integer64
:End:

extern int64 FFI_NewData P(( const byte*, int ));

:Begin:
:Function:       FFI_NewData
:Pattern:        FFI`NewData[64][data_String]
:Arguments:      { data }
:ArgumentTypes:  { ByteString }
:ReturnType:     Integer64
:End:

extern void FFI_ReleaseData P(( int64 ));

:Begin:
:Function:       FFI_ReleaseData
:Pattern:        FFI`ReleaseData[64][ptr_Integer]
:Arguments:      { ptr }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

extern void FFI_ReadData P(( int64, int ));

:Begin:
:Function:       FFI_ReadData
:Pattern:        FFI`ReadData[64][ptr_Integer, len_Integer]
:Arguments:      { ptr, len }
:ArgumentTypes:  { Integer64, Integer }
:ReturnType:     Manual
:End:

extern void FFI_WriteData P(( int64, const byte*, int ));

:Begin:
:Function:       FFI_WriteData
:Pattern:        FFI`WriteData[64][ptr_Integer, data_String]
:Arguments:      { ptr, data }
:ArgumentTypes:  { Integer64, ByteString }
:ReturnType:     Manual
:End:

extern int64 FFI_NewClosure P(( int64, int64 ));

:Begin:
:Function:       FFI_NewClosure
:Pattern:        FFI`NewClosure[64][userdata_Integer, funcptr_Integer:0]
:Arguments:      { userdata, funcptr }
:ArgumentTypes:  { Integer64, Integer64 }
:ReturnType:     Integer64
:End:

extern void FFI_ReleaseClosure P(( int64 ));

:Begin:
:Function:       FFI_ReleaseClosure
:Pattern:        FFI`ReleaseClosure[64][ptr_Integer]
:Arguments:      { ptr }
:ArgumentTypes:  { Integer64 }
:ReturnType:     Manual
:End:

extern int64 FFI_ID P(());

:Begin:
:Function:       FFI_ID
:Pattern:        FFI`ID[64][]
:Arguments:      {}
:ArgumentTypes:  {}
:ReturnType:     Integer64
:End:

#define FFI_EXPORTS
#include "ffimain.h"

API HWND FFIInitializeIcon( HINSTANCE hInstance, int nCmdShow) {
    return MLInitializeIcon(hInstance, nCmdShow);
}

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
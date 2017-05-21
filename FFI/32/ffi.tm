typedef unsigned char byte;
typedef __int32 int32;
typedef __int64 int64;

extern int32 FFI_Init P(( int32, int ));

:Begin:
:Function:       FFI_Init
:Pattern:        FFI`Init[32][size_Integer, mode_Integer]
:Arguments:      { size, mode }
:ArgumentTypes:  { Integer32, Integer }
:ReturnType:     Integer32
:End:

extern void FFI_Exit P(( int32 ));

:Begin:
:Function:       FFI_Exit
:Pattern:        FFI`Exit[32][vm_Integer]
:Arguments:      { vm }
:ArgumentTypes:  { Integer32 }
:ReturnType:     Manual
:End:

extern void FFI_Call P(( int32, const byte*, int ));

:Begin:
:Function:       FFI_Call
:Pattern:        FFI`Call[32][vm_Integer, call_String, args:{___?NumberQ}]
:Arguments:      { vm, call, args }
:ArgumentTypes:  { Integer32, ByteString, Manual }
:ReturnType:     Manual
:End:

extern int32 FFI_Load P(( const char* ));

:Begin:
:Function:       FFI_Load
:Pattern:        FFI`Load[32][path_String]
:Arguments:      { path }
:ArgumentTypes:  { String }
:ReturnType:     Integer32
:End:

extern void FFI_Unload P(( int32 ));

:Begin:
:Function:       FFI_Unload
:Pattern:        FFI`Unload[32][handle_Integer]
:Arguments:      { handle }
:ArgumentTypes:  { Integer32 }
:ReturnType:     Manual
:End:

extern int32 FFI_Find P(( int32, const char* ));

:Begin:
:Function:       FFI_Find
:Pattern:        FFI`Find[32][handle_Integer, symbol_String]
:Arguments:      { handle, symbol }
:ArgumentTypes:  { Integer32, String }
:ReturnType:     Integer32
:End:

extern int32 FFI_NewData P(( const byte*, int ));

:Begin:
:Function:       FFI_NewData
:Pattern:        FFI`NewData[32][data_String]
:Arguments:      { data }
:ArgumentTypes:  { ByteString }
:ReturnType:     Integer32
:End:

extern void FFI_ReleaseData P(( int32 ));

:Begin:
:Function:       FFI_ReleaseData
:Pattern:        FFI`ReleaseData[32][ptr_Integer]
:Arguments:      { ptr }
:ArgumentTypes:  { Integer32 }
:ReturnType:     Manual
:End:

extern void FFI_ReadData P(( int32, int ));

:Begin:
:Function:       FFI_ReadData
:Pattern:        FFI`ReadData[32][ptr_Integer, len_Integer]
:Arguments:      { ptr, len }
:ArgumentTypes:  { Integer32, Integer }
:ReturnType:     Manual
:End:

extern void FFI_WriteData P(( int32, const byte*, int ));

:Begin:
:Function:       FFI_WriteData
:Pattern:        FFI`WriteData[32][ptr_Integer, data_String]
:Arguments:      { ptr, data }
:ArgumentTypes:  { Integer32, ByteString }
:ReturnType:     Manual
:End:

extern int32 FFI_NewClosure P(( int32, int32 ));

:Begin:
:Function:       FFI_NewClosure
:Pattern:        FFI`NewClosure[32][userdata_Integer, funcptr_Integer:0]
:Arguments:      { userdata, funcptr }
:ArgumentTypes:  { Integer32, Integer32 }
:ReturnType:     Integer32
:End:

extern void FFI_ReleaseClosure P(( int32 ));

:Begin:
:Function:       FFI_ReleaseClosure
:Pattern:        FFI`ReleaseClosure[32][ptr_Integer]
:Arguments:      { ptr }
:ArgumentTypes:  { Integer32 }
:ReturnType:     Manual
:End:

extern int32 FFI_ID P(());

:Begin:
:Function:       FFI_ID
:Pattern:        FFI`ID[32][]
:Arguments:      {}
:ArgumentTypes:  {}
:ReturnType:     Integer32
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
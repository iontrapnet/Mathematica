#include "WolframLibrary.h"
__declspec(dllexport) mint libData(WolframLibraryData libData,
			mint Argc, MArgument *Args, MArgument Res) {
	MArgument_setInteger(Res, (mint)libData);
    return LIBRARY_NO_ERROR;
}
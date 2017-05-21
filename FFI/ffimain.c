
#include "ffimain.h"

#if WINDOWS_MATHLINK

#if __BORLANDC__
#pragma argsused
#endif

int PASCAL WinMain( HINSTANCE hinstCurrent, HINSTANCE hinstPrevious, LPSTR lpszCmdLine, int nCmdShow)
{
	char  buff[512];
	char FAR * buff_start = buff;
	char FAR * argv[32];
	char FAR * FAR * argv_end = argv + 32;

    hinstPrevious = hinstPrevious; // suppress warning

	if( !FFIInitializeIcon( hinstCurrent, nCmdShow)) return 1;
	MLScanString( argv, &argv_end, &lpszCmdLine, &buff_start);
	return FFIMain( (int)(argv_end - argv), argv);
}

#else

extern int FFIMain(int argc, char* argv[]);
	
int main(argc, argv)
	int argc; char* argv[];
{
	return FFIMain(argc, argv);
}

#endif
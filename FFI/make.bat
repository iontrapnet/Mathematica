@echo off
SET ARCH=%1
set "VCDir=D:\Develop\Visual Studio 2010 Ultimate\"
@call "%VCDir%vcvars%ARCH%.bat"
SET CL=/nologo /c /DWIN32 /D_WINDOWS /W3 /O2 /DNDEBUG
SET LINK=/NOLOGO /SUBSYSTEM:windows /INCREMENTAL:no /PDB:NONE kernel32.lib user32.lib gdi32.lib

rem cd %ARCH%
rem MPREP ffi.tm -o ffitm.c
rem CL /I . /I .. /I dyncall\include ..\ffi.cc ffitm.c
rem LINK ffi.obj ffitm.obj ml%ARCH%i4m.lib /LIBPATH:dyncall\lib libdyncall_s.lib libdynload_s.lib libdyncallback_s.lib /DLL /OUT:ffi.dll
rem tcc\tiny_impdef ffi.dll
rem tcc\tcc ml%ARCH%i4.def ..\ffimain.c ffi.def -o ffi.exe
rem cd ..

%ARCH%\MPREP ffi%ARCH%.tm -o ffitm.c
CL /I . /I %ARCH% /I %ARCH%\dyncall\include ffi.cc ffitm.c
LINK ffi.obj ffitm.obj /LIBPATH:%ARCH% ml%ARCH%i4m.lib /LIBPATH:%ARCH%\dyncall\lib libdyncall_s.lib libdynload_s.lib libdyncallback_s.lib /DLL /OUT:ffi.dll
%ARCH%\tcc\tiny_impdef ffi.dll
%ARCH%\tcc\tcc %ARCH%\ml%ARCH%i4.def ffimain.c ffi.def -o ffi.exe

rem cl /c newt.c
rem link /dll newt.obj

rem cl /I %ARCH% /c libData.c
rem link /dll libData.obj
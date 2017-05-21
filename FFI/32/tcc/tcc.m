(* ::Package:: *)

FFI`PtrSize=4;
Needs["FFI`",FileNameJoin[{ParentDirectory@DirectoryName@$InputFileName,"FFI.m"}]]
$ContextPath=Drop[$ContextPath,1];

Begin["tcc`"]

ClearAll[
`New,
`Delete,
`SetLibPath,
`AddIncludePath,
`AddSysincludePath,
`AddFile,
`CompileString,
`SetOutputType,
`AddLibraryPath,
`AddSymbol,
`Relocate,
`GetSymbol,
`LibTcc,
`Init,
`Inited,
`Exit,
`State,
`Reset,
`Source,
`File,
`Include,
`Lib,
`Symbol,
`Link,
`Get,
`Def,
`$,
`$New,
`$Delete,
`$SetLibPath,
`$AddIncludePath,
`$AddSysincludePath,
`$AddFile,
`$CompileString,
`$SetOutputType,
`$AddLibraryPath,
`$AddSymbol,
`$Relocate,
`$GetSymbol,
`$LibTcc,
`$Init,
`$Inited,
`$Exit,
`$State,
`$Reset,
`$Source,
`$File,
`$Include,
`$Lib,
`$Symbol,
`$Link,
`$Get,
`$Def
]

`$={
`New->`$New,
`Delete->`$Delete,
`SetLibPath->`$SetLibPath,
`AddIncludePath->`$AddIncludePath,
`AddSysincludePath->`$AddSysincludePath,
`AddFile->`$AddFile,
`CompileString->`$CompileString,
`SetOutputType->`$SetOutputType,
`AddLibraryPath->`$AddLibraryPath,
`AddSymbol->`$AddSymbol,
`Relocate->`$Relocate,
`GetSymbol->`$GetSymbol,
`LibTcc->`$LibTcc,
`Init->`$Init,
`Inited->`$Inited,
`Exit->`$Exit,
`State->`$State,
`Reset->`$Reset,
`Source->`$Source,
`File->`$File,
`Include->`$Include,
`Lib->`$Lib,
`Symbol->`$Symbol,
`Link->`$Link,
`Get->`$Get,
`Def->`$Def
};

Begin["`Private`"]

ClearAll[
`DIR,
`DLL
]

`DIR=DirectoryName[$InputFileName];
`DLL=FileNameJoin[{`DIR,"libtcc.dll"}];

End[];

`Init[]:=Block[{},
If[`Inited===True,Return[],`Inited=True];
`LibTcc=FFI`Lib[`Private`DLL];
{
`New,
`Delete,
`SetLibPath,
`AddIncludePath,
`AddSysincludePath,
`AddFile,
`CompileString,
`SetOutputType,
`AddLibraryPath,
`AddSymbol,
`Relocate,
`GetSymbol
}=FFI`Def[`LibTcc,"
int tcc_new();
void tcc_delete(int);
void tcc_set_lib_path(int, char* );
int tcc_add_include_path(int, char* );
int tcc_add_sysinclude_path(int, char* );
int tcc_add_file(int, char* );
int tcc_compile_string(int, char* );
int tcc_set_output_type(int, int);
int tcc_add_library_path(int, char* );
int tcc_add_symbol(int, char*, int);
int tcc_relocate(int, int);
int tcc_get_symbol(int, char* );
"];
`Reset[];
];

`Exit[]:=Block[{},
If[`Inited===True,
`Delete[`State];
FFI`Unlib[`LibTcc];
`Inited=False];
];

`Reset[]:=Block[{},
If[Head[`State]===Integer,`Delete[`State]];
`State=`New[];
`SetLibPath[`State,FileNameJoin[{`Private`DIR,"lib"}]];
`AddSysincludePath[`State,FileNameJoin[{`Private`DIR,"include"}]];
`SetOutputType[`State,0];
`Include[FileNameJoin[{`Private`DIR,"include"}]];
`Lib[FileNameJoin[{`Private`DIR,"lib"}]];
];

`Source[code_String]:=`CompileString[`State,code];

`File[path_String]:=`AddFile[`State,path];

`Include[path_String]:=`AddIncludePath[`State,path];

`Lib[path_String]:=`AddLibraryPath[`State,path];

`Symbol[name_String,addr_Integer]:=`AddSymbol[`State,name,addr];

`Link[ptr_Integer]:=`Relocate[`State,ptr];

`Link[]:=Module[{size=`Link[0],ptr},
If[size<0,Return[size]];
ptr=FFI`New[size];
`Link[ptr];
ptr
];

`Get[name_String]:=`GetSymbol[`State,name];

`Def[type_String,name_String,sigstr:{___String},
vm_:FFI`CDefault]:=FFI`Def[type,name,`Get[name],sigstr,vm];

`Def[code_String,vm_:FFI`CDefault]:=
`Def[Sequence@@#,vm]&/@SymbolicC`ToProto[code];

(*ClearAll/@`$[[All,2]];
SetDelayed@@ReleaseHold[#]&/@Flatten[(DownValues/@`$[[All,1]])/.Join[`$,FFI`$]];
SetDelayed@@ReleaseHold[#]&/@Flatten[(SubValues/@`$[[All,1]])/.Join[`$,FFI`$]];*)

End[];

tcc`Init[];
(*tcc`$Init[];*)

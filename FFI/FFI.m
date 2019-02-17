(* ::Package:: *)

(* FFI/CLink *)

Begin["System`"]

ClearAll[
Each,
ReturnType,
ArgTypes,
Convention,
Data,
$0,$1,$2,$3,$4,$5,$6,$7,$8,$9
]

Each[lst_,expr_]:=(expr@@#)&/@lst;

Unprotect[Total];
Total[atom_?AtomQ,args___]:=atom;
Protect[Total];

End[];

Begin["SymbolicC`"]

ClearAll[
FromCDeclareString,
ToProto
]

FromCDeclareString[str_String]:=CDeclare@@StringSplit[str,{" ",";"}];

FromCFunctionString[str_String]:=Module[{type,name,sigstr},
{type,sigstr}=StringSplit[str,"("];
{type,name}={Most[#],Last[#]}&@StringSplit[type];
sigstr=StringSplit[#]&/@StringSplit[sigstr,{",",")",";"}];
CFunction[type,name,sigstr]
];

ToProto[cfunc_CFunction]:=Module[{type,name,sigstr},
type=cfunc[[1]];
type=ToCCodeString[If[Head[type]===List,type[[-1]],type]];
name=ToCCodeString[cfunc[[2]]];
sigstr=ToCCodeString[If[Head[#]===List,#[[1]],#]]&/@cfunc[[3]];
{type,name,sigstr}
];

ToProto[code_String]:=ToProto/@FromCFunctionString/@StringSplit[code,"\n"];

End[];

(* Encode/Decode *)

BeginPackage["FFI`"]

ClearAll[
`Types,
`Type,
`Aligns,
`Align,
`TypeAlign,
`TypeSize,
`TypeInfer,
`TypeEncode,
`SizeEncode,
`TypeDecode,
`SigEncode,
`SigDecode,
`ProtoEncode,
`ArgEncode,
`ArgDecode,
`StructEncode,
`StructDecode,
`InvokeEncode,
`CallEncode
]

If[!ValueQ@`PtrSize,
`PtrSize = If[$ProcessorType == "x86-64",8,4];
];

`PtrType="Integer"<>ToString[`PtrSize*8];

`Types = {__ ~~ "*" -> `PtrType, "int" -> "Integer32", 
   "long" -> "Integer64", "float" -> "Real32", "double" -> "Real64", 
   "void" -> "Void", "char" -> "Integer8", "short" -> "Integer16"};

`Aligns = {"Integer8" -> `PtrType, "Integer16" -> `PtrType};

`Type = (StringReplace[#, `Types]) &;

`Align = (# /. `Aligns) &;

`TypeAlign = `Align[`Type[#]] &;

`TypeSize = Total[(`Type[#] /. {"Integer8" -> 1, "Integer16" -> 2, "Integer32" -> 4, "Integer64" -> 8, 
      "Real32" -> 4, "Real64" -> 8}), Infinity] &;

`TypeInfer = Switch[Head[#], 
	Integer, If[IntegerLength[#, 256] > 4, "Integer64", "Integer32"], 
	Real,"Real64",
	String,`PtrType
	] &;

`TypeEncode = (`TypeAlign[#] /. {"Integer32" -> 0, "Integer64" -> 1, 
      "Real32" -> 2, "Real64" -> 3, "Void" -> 0(* 
      only used as return type, encode same as PtrType, 
      just ignore returned value *)}) &;

`SizeEncode[0] = ExportString[0, "Byte"];

`SizeEncode[size_Integer] := 
  Module[{bytesize = IntegerLength[size*4, 256], bytes},
   If[bytesize > 4, Message[General::args],
    bytes = IntegerDigits[size, 256, bytesize];
    bytes[[1]] = BitOr[bytes[[1]], 64*(bytesize - 1)]; 
    StringJoin @@ (ExportString[#, "Byte"] & /@ bytes)]
   ];

`SigEncode[{}] = `SizeEncode[0];

`SigEncode[sigstr : {__String}] := Module[{sigs = `TypeEncode[sigstr]},
   sigs = Partition[sigs, 4, 4, {1, 1}, 0];
   `SizeEncode[Length[sigstr]] <> 
    StringJoin @@ (ExportString[FromDigits[#, 4], "Byte"] & /@ sigs)
   ];

`TypeDecode = (# /. {0 -> "Integer32", 1 -> "Integer64", 
      2 -> "Real32", 3 -> "Real64"(*,4\[Rule]"Void"*)}) &;

`SigDecode[str_String] := 
  Module[{bytes = ImportString[str, "Byte"], ptr = 0, bytesize, size},
   bytesize = BitShiftRight[bytes[[ptr + 1]], 6] + 1;
   bytes[[ptr + 1]] = BitAnd[bytes[[ptr + 1]], 63];
   size = FromDigits[bytes[[ptr + 1 ;; ptr + bytesize]], 256];
   ptr += bytesize;
   bytesize = Ceiling[size/4];
   `TypeDecode[
    Flatten[IntegerDigits[#, 4, 4] & /@ 
       bytes[[ptr + 1 ;; ptr + bytesize]], 1][[1 ;; size]]]
   ];

`ProtoEncode[type_String, sigstr : {___String}] := `SigEncode[
   Append[sigstr, type]];

`ArgEncode[{}, {}] = "";

`ArgEncode[data : {___?NumericQ}, sigstr : {___String}] := 
  ExportString[data, "Binary", "DataFormat" -> `Type /@ sigstr];

`ArgDecode[str_String, sigstr : {___String}] := 
If[Length[#]===1,#[[1]],#]&@ImportString[str, "Binary", "DataFormat" -> `Type /@ sigstr];

`ArgDecode[str_String, sigstr_String] := 
If[ListQ[#],Flatten[#,1],#]&@`ArgDecode[str,{sigstr}];

`ArgEncode[] = "";

`ArgEncode[data : PatternSequence[(_?NumericQ -> _String)] ..] := 
  StringJoin @@ (Table[
     ExportString[item[[1]], `Type@item[[2]]], {item, {data}}]);

`ArgEncode[data : PatternSequence[(_?NumericQ)] ..] := `ArgEncode[
   Sequence @@ Table[item -> `TypeInfer[item], {item, {data}}]];

`StructEncode[data_List, sigstr_List] := `ArgEncode[Flatten[data], 
   Flatten[sigstr]];

`StructEncode[data__Rule] := `ArgEncode[Flatten[Thread /@ {data}]];

`StructDecode = `ArgDecode[#1, Flatten[#2]] &;

`InvokeEncode[addr_Integer, data : {___?NumericQ}, 
   sigstr : {___String}] := `ArgEncode[Append[data, addr], 
Append[sigstr, `PtrType]];

`InvokeEncode[addr_Integer, 
   data : PatternSequence[(_?NumericQ -> _String)] ...] := `ArgEncode[
   data, addr ->`PtrType];

`CallEncode[type_String, addr_Integer, sigstr : {___String}] := 
`InvokeEncode[addr]<>`ProtoEncode[type, sigstr];
(* Seems sometimes funptr isn't aligned to 4 bytes, like tcc_relocate
so ExportString[BitOr[addr,`TypeEncode[type]],`PtrType] doesn't \
work *)

EndPackage[];
$ContextPath = Drop[$ContextPath, 1];

(* Invoke/Callback *)

Begin["FFI`"]

ClearAll[
`Install,
`Installed,
`Uninstall,
`CDefault,
`CEllipsis,
`x86CDecl,
`x86Std,
`Run,
`Apply,
`Def,
`CreateLibs,
`ClearLibs,
`CreateVars,
`ClearVars,
`Libs,
`Lib,
`Unlib,
`Func,
`LibC,
`LibML,
`LibObject,
`LibHandle,
`FuncObject,
`FuncHandle,
`FuncType,
`FuncProto,
`DefaultClosureHandler,
`NewFunc,
`ReleaseFunc,
`Str,
`Buf,
`New,
`Vars,
`Scope,
`Var,
`Begin,
`End,
`Block,
`Read,
`Write,
`Object
]

Begin["`Private`"]

ClearAll[
`DIR,
`EXE,
`StdLink,
`AuxLink
]

`DIR=DirectoryName[$InputFileName];
`EXE=FileNameJoin@{`DIR,If[$OperatingSystem=="Windows","ffi.exe","ffi"]};

End[];

`Install[]:=Block[{},
If[`Installed===True,Return[],`Installed=True];
ClearAll[
`Init,
`Exit,
`Call,
`Load,
`Unload,
`Find,
`NewData,
`ReleaseData,
`ReadData,
`WriteData,
`NewClosure,
`ReleaseClosure,
`ID,
`CDefault,
`Libs,
`LibC,
`LibM,
`LibML,
`Str,
`Vars,
`Scope,
`Var
];
`Private`StdLink=Install[`Private`EXE];
(* `Private`AuxLink=LinkCreate["FFI_aux"];
JLink`ShareKernel[`Private`AuxLink]; *)
`CDefault=`Init[4096,0];
`CreateLibs[];
`CreateVars[];
];

`Uninstall[]:=Block[{},
If[`Installed===True,
`ClearVars[];
`ClearLibs[];
`Exit[`CDefault];
(* `ReleaseClosure[0];
JLink`UnshareKernel[`Private`AuxLink];
LinkClose[`Private`AuxLink]; *)
Uninstall[`Private`StdLink];
`Installed=False;]
];

`CreateLibs[]:=Block[{},
`Libs={"FFI"->{0,{}}};
`Lib[path_String]:=Module[{handle=`Load[path]},
If[handle>0,
PrependTo[`Libs,path->{handle,{}}];
`Lib[path]=`LibObject[path],
Message[General::args,path];$Failed]
];
`Func[path_String,name_String]:=Module[{index=Position [`Libs,path,2],handle},
If[index==={},
`Lib[path];index=1,
index=index[[1,1]]];
If[(handle=`Find[`Libs[[index,2,1]],name])>0,AppendTo[`Libs[[index,2,2]],name->handle];
`Func[handle]=`Func[name]=`Func[path,name]=`FuncObject[path,name],
Message[General::args,name];$Failed]
];
`Func[path_String,name_Symbol]:=`Func[path,ToString[name]];
`Func[name_String]:=Module[{r},
Off[General::args];Do[If[(r=`Func[lib[[1]],name])=!=$Failed,Break[]],{lib,`Libs}];
On[General::args];r
];
`Func[name_Symbol]:=`Func[ToString[name]];
Switch[$OperatingSystem,
"Windows",`LibC=`Lib["msvcrt.dll"];`LibM=`LibC;`LibML=`Lib["ml"<>ToString[8*`PtrSize]<>"i4.dll"];,
"Unix",`LibC=`Lib["libc.so.6"];`LibM=`Lib["libm.so.6"];`LibML=`Lib["libML"<>ToString[8*`PtrSize]<>"i4.so"];
];
];

`ClearLibs[]:=Block[{},
`Unload/@`Libs[[All,2,1]];
ClearAll[`Libs,`Lib,`Func];
];

`CreateVars[]:=Block[{},
`Vars={};
`Scope={};
`Str=(#<>FromCharacterCode[0])&;
`Var=AppendTo[`Vars[[Sequence@@`Scope]],`New[##]][[-1]]&;
];

`ClearVars[]:=Block[{},
`ReleaseData/@Flatten[`Vars];
ClearAll[`Vars,`Scope,`Var];
];

`Unlib[path_String]:=Block[{index=Position[`Libs,path,2]},
If[index==={},Return[],index=index[[1,1]]];
(`Func[#[[1]]]=.;`Func[path,#[[1]]]=.)&/@`Libs[[index,2,2]];
`Unload[`Libs[[index,2,1]]];
`Lib[path]=.;
`Libs=Delete[`Libs,index];
];

`Unlib[obj_`LibObject]:=`Unlib@@obj;

`Run[type_String,addr_Integer,sigstr:{___String},args:{___?NumberQ},
vm_:`CDefault]:=Module[{result=`Call[vm,`CallEncode[type,addr,sigstr],args]},
If[MemberQ[{"void","Void"},type],Null,result]
];

`Run[type_String,obj_`FuncObject,sigstr:{___String},data:{___?NumberQ},
vm_:`CDefault]:=`Run[type,`FuncHandle[obj],sigstr,data,vm];

`Run[type_String,name__String,sigstr:{___String},data:{___?NumberQ},
vm_:`CDefault]:=`Run[type,`Func[name],sigstr,data,vm];

Options[`Apply]={ReturnType->`PtrType,ArgTypes-> Automatic,Convention->`CDefault};

`Apply[addr_Integer,args:{___?NumberQ},
OptionsPattern[]]:=Module[
{type=OptionValue[ReturnType],sigstr=OptionValue[ArgTypes]},
If[sigstr===Automatic,sigstr=`TypeInfer/@args];
`Run[type,addr,sigstr,args,OptionValue[Convention]]];

`Def[type_String,addr_Integer,sigstr:{___String},
vm_:`CDefault]:=(`FuncType[addr]={ReturnType->type,ArgTypes->sigstr};
ToExpression["$1["<>ToString[vm]<>",$2,{##}]&"]
/.{$1->`Call,$2->`CallEncode[type,addr,sigstr]});

`Def[type_String,name__String,addr_Integer,sigstr:{___String},
vm_:`CDefault]:=Module[{argc=Length[sigstr],flag=And@@StringFreeQ[sigstr,__ ~~ "*"]},
`FuncType[addr]={ReturnType->type,ArgTypes->sigstr};
ToExpression["Function[Null,If[Length[{##}]===$1,"<>
If[flag,"","$2["]<>"$3[$4,$5,"<>If[flag,"","If[NumberQ[#],#,$6[#]]&/@"]
<>"{##}]"<>If[flag,"","]"]<>If[MemberQ[{"void","Void"},type],";",""]<>
",Message[General::argrx,$7,Length[{##}],$8];$Failed],{HoldAll}]"]
/.{$1->argc,$2->`Block,$3->`Call,$4->vm,$5->`CallEncode[type,addr,sigstr],
$6->`Var,$7->FileNameJoin[{name}],$8->argc}
];

`Def[type_String,obj_`FuncObject,sigstr:{___String},
vm_:`CDefault]:=`Def[type,obj[[1]],obj[[2]],`FuncHandle[obj],sigstr,vm];

`Def[type_String,name__String,sigstr:{___String},
vm_:`CDefault]:=`Def[type,`Func[name],sigstr,vm];

`Def[code_String,vm_:`CDefault]:=
`Def[Sequence@@#,vm]&/@SymbolicC`ToProto[code];

`Def[path_String,code_String,vm_:`CDefault]:=
`Def[Sequence@@Insert[#,path,2],vm]&/@SymbolicC`ToProto[code];

`Def[obj_`LibObject,code_String,vm_:`CDefault]:=`Def[obj[[1]],code,vm];

`LibObject[path_String][name:(_String|_Symbol)]:=`Func[path,name];

`LibObject[path_String][(name:(_String|_Symbol))[args___]]:=`LibObject[path][name][args];

`LibHandle[path_String]:=(path/.`Libs)[[1]];

`LibHandle[obj_`LibObject]:=`LibHandle@@obj;

`FuncObject[path_String,name_String][args___,
opts:OptionsPattern[]]:=
`Block[`Apply[`FuncHandle[path,name],If[NumberQ[#],#,`Var[#]]&/@{args},
opts,Sequence@@`FuncType[path,name]]];

`FuncHandle[path_String,name_String]:=name/.(path/.`Libs)[[2]];

`FuncHandle[obj_`FuncObject]:=`FuncHandle@@obj;

`FuncHandle[name_String]:=`FuncHandle[`Func[name]];

`FuncType[addr_Integer]={};

`FuncType[path_String,name_String]:=`FuncType[`FuncHandle[path,name]];

`FuncType[obj_`FuncObject]:=`FuncType@@obj;

`FuncType[name_String]:=`FuncType[`FuncHandle[name]];

`FuncType[addr_Integer,opts:OptionsPattern[]]:=(`FuncType[addr]={opts});

`FuncType[path_String,name_String,opts:OptionsPattern[]]:=(`FuncType[path,name]={opts});

`FuncType[obj_`FuncObject,opts:OptionsPattern[]]:=(`FuncType[obj]={opts});

`FuncType[name_String,opts:OptionsPattern[]]:=(`FuncType[name]={opts});

`FuncProto[addr_Integer]:=
{ReturnType/.`FuncType[addr],`Func[addr][[2]],ArgTypes/.`FuncType[addr]};

`FuncProto[path_String,name_String]:=`FuncProto[`FuncHandle[path,name]];

`FuncProto[obj_`FuncObject]:=`FuncProto@@obj;

`FuncProto[name_String]:=`FuncProto[`FuncHandle[name]];

`NewFunc[type_String,sigstr:{___String},expr_]:=Module[{userdata,name,handle},
userdata=`NewData[`ArgEncode[0->`PtrType]<>`ProtoEncode[type,sigstr]];
name=IntegerString[userdata,16,`PtrSize*2];
(* JLink`ShareKernel[LinkCreate["FFI_"<>name]]; *)
handle=`NewClosure[userdata,0];
AppendTo[`Libs[[-1,2,2]],name->handle];
`DefaultClosureHandler[handle,args_List]:=expr@@args;
`Func[handle]=`Func[name]=`Func["FFI",name]=`FuncObject["FFI",name]
];

`ReleaseFunc[obj_`FuncObject]:=Module[{name=obj[[2]],handle=`FuncHandle[obj],kernel},
`Func[handle]=.;
`Func[name]=.;
`Func["FFI",name]=.;
`DefaultClosureHandler[handle,args_List]=.;
`Libs[[-1,2,2]]=DeleteCases[`Libs[[-1,2,2]],name->handle];
`ReleaseClosure[handle];
(* kernel=Cases[Links[],LinkObject["FFI_"<>name,_,_]][[1]];
JLink`UnshareKernel[kernel];
LinkClose[kernel]; *)
`ReleaseData[FromDigits[name,16]]
];

`Buf[size_Integer,init_Integer:0]:=
StringJoin@@ConstantArray[FromCharacterCode[init],size];

`New[Data[str_String]]:=`NewData[str];

`New[Data[data:{__Integer}]]:=`NewData[FromCharacterCode@data];

`New[size_Integer,init_Integer:0]:=`NewData[`Buf[size,init]];

`New[str_String]:=`NewData[`Str[str]];

`New[{data___}]:=`NewData[`ArgEncode[data]];

`Begin[]:=(AppendTo[`Vars[[Sequence@@`Scope]],{}];AppendTo[`Scope,-1]);

`End[]:=(`ReleaseData/@Flatten[`Vars[[Sequence@@`Scope]]];`Vars=Delete[`Vars,`Scope];
`Scope=Drop[`Scope,-1]);

SetAttributes[`Block,HoldAll];

`Block[expr_]:=Block[{r},
`Begin[];
r=expr;
`End[];
r
];

`Read[addr_Integer]:=`ReadData[addr,`LibC@"strlen"[addr]];

`Read[addr_Integer,size_Integer]:=ImportString[`ReadData[addr,size],"Byte"];

`Read[addr_Integer,sigstr:({___String}|_String),size_Integer:1]:=
`ArgDecode[`ReadData[addr,size*`TypeSize[sigstr]],sigstr];

`Write[addr_Integer,Data[str_String]]:=`WriteData[addr,str];

`Write[addr_Integer,size_Integer,init_Integer:0]:=`WriteData[addr,`Buf[size,init]];

`Write[addr_Integer,str_String]:=`WriteData[addr,`Str[str]];

`Write[addr_Integer,{data___}]:=`WriteData[addr,`ArgEncode[data]];

(* $,$$,!,!! *)
`Object /: Factorial[`Object[ptr_Integer, args___]] := ptr;
`Object /: Format[`Object[ptr_Integer]] := 
  "String: " <> IntegerString[ptr, 16, 2 `PtrSize];
`Object /: 
  Format[`Object[ptr_Integer, type_String, size_Integer: 1]] := 
  `Type@type <> "[" <> ToString@size <> "]: " <> 
   IntegerString[ptr, 16, 2 `PtrSize];
`Object /: 
  Format[`Object[ptr_Integer, types : {__String}, 
    size_Integer: 1]] := 
  "{" <> StringJoin[Riffle[`Type /@ types, ","]] <> "}[" <> 
   ToString@size <> "]: " <> IntegerString[ptr, 16, 2 `PtrSize];

`Object[str_String] := `Object[`Var@str];
`Object[data : {___?NumericQ}, type_String] := 
  `Object[`Var[{data, {type}}], type, Length@data];
`Object[data : {(_?NumericQ -> _String) ...}] := 
  `Object[`Var[data], Last /@ data];
`Object[data : {{__?NumericQ} ...}, types : {__String}] :=
  `Object[`Var[{Flatten@data, types}], types, Length@data];

`Object[ptr_Integer, args___][] := `Read[ptr, args];
`Object[ptr_Integer, type_String, size_Integer: 1][k_Integer] := 
  `Read[ptr + k `TypeSize@type, type][[1]];
`Object[ptr_Integer, type_String, size_Integer: 1][
   k_Integer -> v_] := 
  `Write[ptr + k `TypeSize@type, Data@`ArgEncode[v -> type]];
`Object[ptr_Integer, types : {__String}, size_Integer: 1][
   k_Integer] := 
  `Read[ptr + 
     Total[`TypeSize@types[[Mod[# - 1, Length@types] + 1]] & /@ 
       Range[k]], types[[Mod[k, Length@types] + 1]]][[1]];
`Object[ptr_Integer, types : {__String}, size_Integer: 1][
   k_Integer -> v_] := 
  `Write[
   ptr + Total[
     `TypeSize@types[[Mod[# - 1, Length@types] + 1]] & /@ 
      Range[k]], 
   Data@`ArgEncode[v -> types[[Mod[k, Length@types] + 1]]]];
`Object[ptr_Integer, args___][
   kv : {(_Integer | (_Integer -> _)) ...}] := 
  `Object[ptr, args] /@ kv;

End[];

(* AppendTo[$ContextPath, "FFI`"]; *)
Begin["FFI`"]

ClearAll[
`$,
`$Install,
`$Installed,
`$Uninstall,
`$Init,
`$Exit,
`$Call,
`$Load,
`$Unload,
`$Find,
`$NewData,
`$ReleaseData,
`$ReadData,
`$WriteData,
`$NewClosure,
`$ReleaseClosure,
`$ID,
`$CDefault,
`$Libs,
`$LibC,
`$LibM,
`$LibML,
`$Str,
`$Vars,
`$Scope,
`$Var
];

`$={
`Init->`$Init,
`Exit->`$Exit,
`Call->`$Call,
`Load->`$Load,
`Unload->`$Unload,
`Find->`$Find,
`NewData->`$NewData,
`ReleaseData->`$ReleaseData,
`ReadData->`$ReadData,
`WriteData->`$WriteData,
`NewClosure->`$NewClosure,
`ReleaseClosure->`$ReleaseClosure,
`ID->`$ID,
`CDefault->`$CDefault,
`Run->`$Run,
`Apply->`$Apply,
`Def->`$Def,
`CreateLibs->`$CreateLibs,
`ClearLibs->`$ClearLibs,
`CreateVars->`$CreateVars,
`ClearVars->`$ClearVars,
`Lib->`$Lib,
`Unlib->`$Unlib,
`Libs->`$Libs,
`Func->`$Func,
`LibC->`$LibC,
`LibM->`$LibM,
`LibML->`$LibML,
`LibObject->`$LibObject,
`LibHandle->`$LibHandle,
`FuncObject->`$FuncObject,
`FuncHandle->`$FuncHandle,
`FuncType->`$FuncType,
`FuncProto->`$FuncProto,
`DefaultClosureHandler->`$DefaultClosureHandler,
`NewFunc->`$NewFunc,
`ReleaseFunc->`$ReleaseFunc,
`Str->`$Str,
`Buf->`$Buf,
`New->`$New,
`Vars->`$Vars,
`Var->`$Var,
`Scope->`$Scope,
`Begin->`$Begin,
`End->`$End,
`Block->`$Block,
`Read->`$Read,
`Write->`$Write,
`Object->`$Object
};

Begin["`Private`"]

ClearAll[
`DLL
]

`DLL=FileNameJoin@{`DIR,
Switch[$OperatingSystem,
"Windows","ffi.dll",
"Unix","libffi.so"
]};

End[];

`$Install[]:=Block[{},
If[`$Installed===True,Return[],`$Installed=True];
(* OwnValues *)
ClearAll[
`$Init,
`$Exit,
`$Call,
`$Load,
`$Unload,
`$Find,
`$NewData,
`$ReleaseData,
`$ReadData,
`$WriteData,
`$NewClosure,
`$ReleaseClosure,
`$ID,
`$CDefault,
`$Libs,
`$LibC,
`$LibM,
`$LibML,
`$Str,
`$Vars,
`$Scope,
`$Var
];
Each[{
{`$Init,{Integer,Integer},Integer},
{`$Exit,{Integer},"Void"},
{`$Call,LinkObject,LinkObject},
{`$Load,{"UTF8String"},Integer},
{`$Unload,{Integer},"Void"},
{`$Find,{Integer,"UTF8String"},Integer},
{`$NewData,LinkObject,LinkObject},
{`$ReleaseData,{Integer},"Void"},
{`$ReadData,LinkObject,LinkObject},
{`$WriteData,LinkObject,LinkObject},
{`$NewClosure,{Integer,Integer},Integer},
{`$ReleaseClosure,{Integer},"Void"},
{`$ID,{},Integer}
},(#1=LibraryFunctionLoad[`Private`DLL,"FFI_"<>SymbolName[#1],#2,#3])&];
Options[`$Apply]={ReturnType->`PtrType,ArgTypes-> Automatic,Convention->`$CDefault};
SetAttributes[`$Block,HoldAll];
`$CDefault=`$Init[4096,0];
`$CreateLibs[];
`$CreateVars[];
];

`$Uninstall[]:=Block[{},
If[`$Installed===True,
`$ClearVars[];
`$ClearLibs[];
`$Exit[`$CDefault];
LibraryUnload[`Private`DLL];
`$Installed=False;]
];

(* DownValues/SubValues/UpValues? *)
ClearAll/@`$[[All,2]];
SetDelayed@@ReleaseHold[#]&/@Flatten[(DownValues/@`$[[All,1]])/.`$];
SetDelayed@@ReleaseHold[#]&/@Flatten[(SubValues/@`$[[All,1]])/.`$];

(* $,$$,!,!! *)
`$Object /: Factorial[`$Object[ptr_Integer, args___]] := ptr;
`$Object /: Format[`$Object[ptr_Integer]] := 
  "String: " <> IntegerString[ptr, 16, 2 `PtrSize];
`$Object /: 
  Format[`$Object[ptr_Integer, type_String, size_Integer: 1]] := 
  `Type@type <> "[" <> ToString@size <> "]: " <> 
   IntegerString[ptr, 16, 2 `PtrSize];
`$Object /: 
  Format[`$Object[ptr_Integer, types : {__String}, 
    size_Integer: 1]] := 
  "{" <> StringJoin[Riffle[`Type /@ types, ","]] <> "}[" <> 
   ToString@size <> "]: " <> IntegerString[ptr, 16, 2 `PtrSize];
   
End[];
(* $ContextPath=Drop[$ContextPath, -1]; *)

(* Needs["JLink`"]; *)
Needs["SymbolicC`"];

FFI`Install[];
(*FFI`$Install[];*)

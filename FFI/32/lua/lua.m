(* ::Package:: *)

FFI`PtrSize=4;
Needs["FFI`",FileNameJoin[{ParentDirectory@DirectoryName@$InputFileName,"FFI.m"}]]
$ContextPath=Drop[$ContextPath,1];

Begin["System`"]

ClearAll[
`lua,
`$lua
]

End[];

Begin["lua`"]

ClearAll[
`L,
`State,
`Lib,
`NewState,
`OpenLibs,
`Ref,
`Unref,
`Close,
`PCall,
`CPCall,
`CreateTable,
`NewUserData,
`GetTable,
`SetTable,
`GetField,
`SetField,
`RawGet,
`RawSet,
`RawGetI,
`RawSetI,
`GetMetaTable,
`SetMetaTable,
`GetFenv,
`SetFenv,
`PushNil,
`PushBoolean,
`PushNumber,
`PushInteger,
`PushString,
`PushLString,
`PushCClosure,
`PushLightUserData,
`ToBoolean,
`ToNumber,
`ToLString,
`ToCFunction,
`ToUserData,
`ToThread,
`ToPointer,
`GetTop,
`SetTop,
`PushValue,
`Remove,
`Insert,
`Replace,
`CheckStack,
`ObjLen,
`Type,
`IsCFunction,
`Next,
`Concat,
`Resume,
`Yield,
`Status,
`XMove,
`GC,
`Error,
`State,
`RegistryIndex,
`EnvironIndex,
`GlobalIndex,
`Init,
`Inited,
`Exit,
`Table,
`Function,
`CFunction,
`Thread,
`Proto,
`CData,
`Value,
`Object,
`Top,
`Stack,
`Pos,
`Push,
`Drop,
`Pop,
`At,
`Get,
`Set,
`Copy,
`Reg,
`Unreg,
`Run,
`Apply,
`Import,
`Export,
`Eval,
`string`dump,
`loadstring,
`loadfile,
`$,
`L,
`$State,
`$Lib,
`$NewState,
`$OpenLibs,
`$Ref,
`$Unref,
`$Close,
`$PCall,
`$CPCall,
`$CreateTable,
`$NewUserData,
`$GetTable,
`$SetTable,
`$GetField,
`$SetField,
`$RawGet,
`$RawSet,
`$RawGetI,
`$RawSetI,
`$GetMetaTable,
`$SetMetaTable,
`$GetFenv,
`$SetFenv,
`$PushNil,
`$PushBoolean,
`$PushNumber,
`$PushInteger,
`$PushString,
`$PushLString,
`$PushCClosure,
`$PushLightUserData,
`$ToBoolean,
`$ToNumber,
`$ToLString,
`$ToCFunction,
`$ToUserData,
`$ToThread,
`$ToPointer,
`$GetTop,
`$SetTop,
`$PushValue,
`$Remove,
`$Insert,
`$Replace,
`$CheckStack,
`$ObjLen,
`$Type,
`$IsCFunction,
`$Next,
`$Concat,
`$Resume,
`$Yield,
`$Status,
`$XMove,
`$GC,
`$Error,
`$State,
`$RegistryIndex,
`$EnvironIndex,
`$GlobalIndex,
`$Init,
`$Inited,
`$Exit,
`$Table,
`$Function,
`$CFunction,
`$Thread,
`$Proto,
`$CData,
`$Value,
`$Object,
`$Top,
`$Stack,
`$Pos,
`$Push,
`$Drop,
`$Pop,
`$At,
`$Get,
`$Set,
`$Copy,
`$Reg,
`$Unreg,
`$Run,
`$Apply,
`$Import,
`$Export,
`$Eval,
`$string`dump,
`$loadstring,
`$loadfile
]

(* "`([^,]+)," \[Rule] "`\1->`$\1," *)
`$={
`L->`$L,
`State->`$State,
`Lib->`$Lib,
`NewState->`$NewState,
`OpenLibs->`$OpenLibs,
`Ref->`$Ref,
`Unref->`$Unref,
`Close->`$Close,
`PCall->`$PCall,
`CPCall->`$CPCall,
`CreateTable->`$CreateTable,
`NewUserData->`$NewUserData,
`GetTable->`$GetTable,
`SetTable->`$SetTable,
`GetField->`$GetField,
`SetField->`$SetField,
`RawGet->`$RawGet,
`RawSet->`$RawSet,
`RawGetI->`$RawGetI,
`RawSetI->`$RawSetI,
`GetMetaTable->`$GetMetaTable,
`SetMetaTable->`$SetMetaTable,
`GetFenv->`$GetFenv,
`SetFenv->`$SetFenv,
`PushNil->`$PushNil,
`PushBoolean->`$PushBoolean,
`PushNumber->`$PushNumber,
`PushInteger->`$PushInteger,
`PushString->`$PushString,
`PushLString->`$PushLString,
`PushCClosure->`$PushCClosure,
`PushLightUserData->`$PushLightUserData,
`ToBoolean->`$ToBoolean,
`ToNumber->`$ToNumber,
`ToLString->`$ToLString,
`ToCFunction->`$ToCFunction,
`ToUserData->`$ToUserData,
`ToThread->`$ToThread,
`ToPointer->`$ToPointer,
`GetTop->`$GetTop,
`SetTop->`$SetTop,
`PushValue->`$PushValue,
`Remove->`$Remove,
`Insert->`$Insert,
`Replace->`$Replace,
`CheckStack->`$CheckStack,
`ObjLen->`$ObjLen,
`Type->`$Type,
`IsCFunction->`$IsCFunction,
`Next->`$Next,
`Concat->`$Concat,
`Resume->`$Resume,
`Yield->`$Yield,
`Status->`$Status,
`XMove->`$XMove,
`GC->`$GC,
`Error->`$Error,
`State->`$State,
`RegistryIndex->`$RegistryIndex,
`EnvironIndex->`$EnvironIndex,
`GlobalIndex->`$GlobalIndex,
`Init->`$Init,
`Inited->`$Inited,
`Exit->`$Exit,
`Table->`$Table,
`Function->`$Function,
`CFunction->`$CFunction,
`Thread->`$Thread,
`Proto->`$Proto,
`CData->`$CData,
`Value->`$Value,
`Object->`$Object,
`Top->`$Top,
`Stack->`$Stack,
`Pos->`$Pos,
`Push->`$Push,
`Drop->`$Drop,
`Pop->`$Pop,
`At->`$At,
`Get->`$Get,
`Set->`$Set,
`Copy->`$Copy,
`Reg->`$Reg,
`Unreg->`$Unreg,
`Run->`$Run,
`Apply->`$Apply,
`Import->`$Import,
`Export->`$Export,
`Eval->`$Eval,
`string`dump->`$string`dump,
`loadstring->`$loadstring,
`loadfile->`$loadfile
};

Begin["`Private`"]

ClearAll[
`DIR,
`DLL
]

`DIR=DirectoryName[$InputFileName];
`DLL=FileNameJoin[{`DIR,"lua51.dll"}];

End[];

`Init[]:=Block[{},
If[`Inited===True,Return[],`Inited=True];
`Lib=FFI`Lib[`Private`DLL];
{
`NewState,
`OpenLibs,
`Ref,
`Unref,
`Close,
`PCall,
`CPCall,
`CreateTable,
`NewUserData,
`GetTable,
`SetTable,
`GetField,
`SetField,
`RawGet,
`RawSet,
`RawGetI,
`RawSetI,
`GetMetaTable,
`SetMetaTable,
`GetFenv,
`SetFenv,
`PushNil,
`PushBoolean,
`PushNumber,
`PushInteger,
`PushString,
`PushLString,
`PushCClosure,
`PushLightUserData,
`ToBoolean,
`ToNumber,
`ToLString,
`ToCFunction,
`ToUserData,
`ToThread,
`ToPointer,
`GetTop,
`SetTop,
`PushValue,
`Remove,
`Insert,
`Replace,
`CheckStack,
`ObjLen,
`Type,
`IsCFunction,
`Next,
`Concat,
`Resume,
`Yield,
`Status,
`XMove,
`GC,
`Error
}=FFI`Def[`Lib,"
int luaL_newstate();
void luaL_openlibs(int);
int luaL_ref(int, int);
void luaL_unref(int, int, int);
void lua_close(int);
int lua_pcall(int, int, int, int);
int lua_cpcall(int, int, int);
void lua_createtable(int, int, int);
int lua_newuserdata(int, int);
void lua_gettable(int, int);
void lua_settable(int, int);
void lua_getfield(int, int, char* );
void lua_setfield(int, int, char* );
void lua_rawget(int, int);
void lua_rawset(int, int);
void lua_rawgeti(int, int, int);
void lua_rawseti(int, int, int);
int lua_getmetatable(int, int);
int lua_setmetatable(int, int);
void lua_getfenv(int, int);
int lua_getfenv(int, int);
void lua_pushnil(int);
void lua_pushboolean(int, int);
void lua_pushnumber(int, double);
void lua_pushinteger(int, int);
void lua_pushstring(int, char* );
void lua_pushlstring(int, char*, int);
void lua_pushcclosure(int, int, int);
void lua_pushlightuserdata(int, int);
int lua_toboolean(int, int);
double lua_tonumber(int, int);
char* lua_tolstring(int, int, int);
int lua_tocfunction(int, int);
int lua_touserdata(int, int);
int lua_tothread(int, int);
int lua_topointer(int, int);
int lua_gettop(int);
void lua_settop(int, int);
void lua_pushvalue(int, int);
void lua_remove(int, int);
void lua_insert(int, int);
void lua_replace(int, int);
int lua_checkstack(int, int);
int lua_objlen(int, int);
int lua_type(int, int);
int lua_iscfunction(int, int);
int lua_next(int, int);
void lua_concat(int, int);
int lua_resume(int, int);
int lua_yield(int, int);
int lua_status(int);
void lua_xmove(int, int, int);
int lua_gc(int, int, int);
int lua_error(int);
"];
`L=`NewState[];
`OpenLibs[`L];
`RegistryIndex=-10000;
`EnvironIndex=-10001;
`GlobalIndex=-10002;
`Top:=`At[`Pos[]];
`Stack:=`At/@Range[`Pos[]];
`string`dump=`Get["string.dump"];
`loadstring=`Get["loadstring"];
`loadfile=`Get["loadfile"];
`Drop[All];
];

`Exit[]:=Block[{},
If[`Inited===True,
`Close[`L];
FFI`Unlib[`Lib];
`Inited=False;]
];

(*TODO: more layers call
support userdata/object's metatable*)

`Table[idx_Integer][key_]:=Module[{pos=`Pos[],r=`Get[`Table[idx],key]},
r=`Export[r];`SetTop[L,pos];r];

`Table[idx_Integer][key_[args___]]:=Module[{pos=`Pos[],r=`Get[`Table[idx],key]},
r=`Export[r[args]];`SetTop[L,pos];r];

`Function[idx_Integer][args___,opts:OptionsPattern[]]:=
`Apply[`Function[idx],{args},opts];

`CFunction[addr_Integer][args__,opts:OptionsPattern[]]:=
`Apply[`CFunction[addr],{args},opts];

`Pos[]:=`GetTop[`L];

`Pos[idx_Integer]:=If[idx<0,`Pos[]+1+idx,idx];

`Push[Null]:=`PushNil[`L];

`Push[True]:=`PushBoolean[`L,1];

`Push[False]:=`PushBoolean[`L,0];

`Push[x_Integer]:=`PushInteger[`L,x];

`Push[x_Real]:=`PushNumber[`L,x];

`Push[x_String]:=`PushLString[`L,Data[x],StringLength[x]];

`Push[x_Symbol]:=`Push[ToString[x]];

`Push[`Object[x_String]]:=FFI`Write[`NewUserData[`L,StringLength[x]],x];

`Push[`Object[x_Integer]]:=`PushLightUserData[`L,x];

`Push[x_CFunction,n_Integer:0]:=If[Length[x]===1,`PushCClosure[`L,x[[1]],n],`Copy@x[[1]]];

`Push[x:(_`Table|_`Function|_`Thread|_`Proto|_`CData|_`Value)]:=`Copy@x[[1]];

`Push[values_List]:=(If[`CheckStack[`L,Length[values]]>0,`Push/@values];);

`Drop[n_Integer]:=(`SetTop[`L,-n-1];);

`Drop[]:=`Drop[1];

`Drop[All]:=`Drop[`Pos[]];

`Pop[n_Integer]:=Module[{r=Table[`Export[`Get[i]],{i,-n,-1}]},
`Drop[n];Switch[Length[r],0,Null,1,r[[1]],_,r]
];

`Pop[]:=`Pop[1];

`Pop[All]:=`Pop[`Pos[]];

`At[pos_Integer]:=Module[{t,r},
t=`Type[`L,pos];
r=Switch[t,
0,Null,
1,`ToBoolean[`L,pos]===1,
2,`Object[`ToUserData[`L,pos]],
3,`ToNumber[`L,pos],
4,FFI`ReadData[`ToLString[`L,pos,0],`ObjLen[`L,pos]],
5,`Table[pos],
6,If[`IsCFunction[`L,pos]===1,If[#===0,None,`CFunction[#]]&@`ToCFunction[`L,pos],`Function[pos]],
7,`Object[FFI`ReadData[`ToUserData[`L,pos],`ObjLen[`L,pos]]],
8,`Thread[pos,`ToThread[`L,pos]],
_,None];
If[r===None,`GetField[`L,`GlobalIndex,"tostring"];`Copy[pos];r=`Run[1,1];
r=Switch[t,
6,`CFunction[pos,r],
9,`Proto[pos,r],
10,`CData[pos,r],
_,None]];
If[r===None,`Value[pos,`ToPointer[`L,pos]],r]
];

`Get[idx_Integer]:=Module[{pos,r},
pos=If[idx>-`RegistryIndex,`Copy[idx];`Pos[],`Pos[idx]];
r=`At[pos];If[idx>-`RegistryIndex,`Drop[]];r];

`Get[key_String]:=Module[{keys=StringSplit[key,"."]},
`GetField[`L,`GlobalIndex,keys[[1]]];
Do[`GetField[`L,-1,keys[[i]]];`Remove[`L,-2],{i,2,Length[keys]}];
`Top];

`Get[key_Symbol]:=`Get[ToString[key]];

`Get[tab_`Table,key_]:=If[tab[[1]]===0,`Get[key],
If[tab[[1]]>-`RegistryIndex,
`RawGetI[`L,`RegistryIndex,tab[[1]]+`RegistryIndex]];
`Push[key];
If[tab[[1]]>-`RegistryIndex,
`GetTable[`L,-2];`Remove[`L,-2],
`GetTable[`L,tab[[1]]]];`Top];

`Set[idx_Integer,value_]:=If[idx>-`RegistryIndex,
If[value===Null,`Unreg[idx],
`Push[value];`RawSetI[`L,`RegistryIndex,idx+`RegistryIndex]],
If[value===Null,`Remove[`L,idx],`Push[value];`Replace[`L,idx]]];

`Set[key_String,value_]:=Module[{keys=StringSplit[key,"."],len},
len=Length[keys];
If[len===1,`Push[value];`SetField[`L,`GlobalIndex,keys[[1]]],
`GetField[`L,`GlobalIndex,keys[[1]]];
Do[`GetField[`L,-1,keys[[i]]];`Remove[`L,-2],{i,2,len-1}];
`Push[value];`SetField[`L,-2,keys[[len]]];`Drop[]]
];

`Set[key_Symbol,value_]:=`Set[ToString[key],value];

`Set[tab_`Table,key_,value_]:=If[tab[[1]]===0,`Set[key,value],
If[tab[[1]]>-`RegistryIndex,
`RawGetI[`L,`RegistryIndex,tab[[1]]+`RegistryIndex]];
`Push[key];`Push[value];
If[tab[[1]]>-`RegistryIndex,
`SetTable[`L,-3];`Drop[],
`SetTable[`L,tab[[1]]]]];

`Copy[idx_Integer]:=If[idx>-`RegistryIndex,
`RawGetI[`L,`RegistryIndex,idx+`RegistryIndex],
`PushValue[`L,idx]];

`Reg[]:=(`Ref[`L,`RegistryIndex]-`RegistryIndex);

`Reg[value_]:=(`Push[value];`Reg[]);

`Unreg[idx_Integer]:=`Unref[`L,`RegistryIndex,idx+`RegistryIndex];

`Run[nargs_Integer,nresults_Integer:0]:=Module[{base=`Pos[]-nargs-1},
`PCall[`L,nargs,If[nresults===0,-1,nresults],0];
`Pop[If[nresults===-1,`Pos[]-base,nresults]]
];

`Run[args_List,nresults_Integer:0]:=(`Push[args];`Run[Length[args],nresults]);

Options[`Apply]={ReturnType->-1};

`Apply[fn:(_`Function|_`CFunction),args_List,OptionsPattern[]]:=
(`Push[fn];`Run[args,OptionValue[ReturnType]]);

`Apply[name:(_String|_Symbol),args_List,OptionsPattern[]]:=
(`Get[name];`Run[args,OptionValue[ReturnType]]);

`Import[{arr_List,rec:{PatternSequence[_->_]...}}]:=Module[
{narr=Length[arr],nrec=Length[rec],idx},
`CreateTable[`L,narr,nrec];
idx=`Pos[];
Do[`Push[arr[[i]]];`RawSetI[`L,idx,i],{i,narr}];
Do[`Push[List@@rec[[i]]];`RawSet[`L,idx],{i,nrec}];
`Table[idx]
];

`Import[code_String]:=(`Apply[`loadstring,{code},ReturnType->0];`Function[`Pos[]]);

`Export[tab_`Table]:=Module[{narr,nrec,arr={},rec={}},
narr=`ObjLen[`L,tab[[1]]];
Do[`RawGetI[`L,tab[[1]],i];AppendTo[arr,`Top];`Drop[],{i,narr}];
If[narr===0,`Push[Null],`Push[narr]];
While[`Next[`L,tab[[1]]]>0,AppendTo[rec,`Get[-2]->`Top];`Drop[]];
{arr,rec}
];

`Export[func_`Function]:=`string`dump[func];

`Export[value_]:=value;

`Eval[code_String]:=(`Import[code];`Run[0,-1]);

(*ClearAll/@`$[[All,2]];
SetDelayed@@ReleaseHold[#]&/@Flatten[(DownValues/@`$[[All,1]])/.Join[`$,FFI`$]];
SetDelayed@@ReleaseHold[#]&/@Flatten[(SubValues/@`$[[All,1]])/.Join[`$,FFI`$]];

Options[`$Apply]={ReturnType->-1};*)

lua=`Table[0];
(*$lua=`$Table[0];*)

Unprotect[Set,Unset];

`Table/:Set[`Table[idx_Integer][key_],value_]:=`Set[`Table[idx],key,value];
Set[tab_Symbol[key_],value_]/;Head[tab]===`Table:=`Set[tab,key,value];
`Table/:Unset[`Table[idx_Integer][key_]]:=`Set[`Table[idx],key,Null];
Unset[tab_Symbol[key_]]/;Head[tab]===`Table:=`Set[tab,key,Null];

(*`$Table/:Set[`$Table[idx_Integer][key_],value_]:=`$Set[`$Table[idx],key,value];
Set[tab_Symbol[key_],value_]/;Head[tab]===`$Table:=`$Set[tab,key,value];
`$Table/:Unset[`$Table[idx_Integer][key_]]:=`$Set[`$Table[idx],key,Null];
Unset[tab_Symbol[key_]]/;Head[tab]===`$Table:=`$Set[tab,key,Null];*)

Protect[Set,Unset];

End[];

lua`Init[];
(*lua`$Init[];*)

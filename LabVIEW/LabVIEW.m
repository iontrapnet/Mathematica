(* ::Package:: *)

If[$VersionNumber < 10,
System`Association[list:{__Rule}][key_]:=key/.list;
System`Association/:System`ReplaceAll[key_,System`Association[list:{__Rule}]]:=key/.list;
]

Needs["NETLink`"];
Off[NET::netexcptn];
Off[LoadNETAssembly::noload];
LoadNETAssembly@FileNameJoin@{DirectoryName@$InputFileName,"LabVIEW.dll"};
On[NET::netexcptn];
Off[LoadNETAssembly::noload];

BeginPackage["IonTrap`"]

AppCls;
VIDir=DirectoryName@$InputFileName<>"\\";

ClearAll[LoadVI]
ClearAll[MakeAndCastNETObject]
ClearAll[CallVI]
ClearAll[CurrentTimeString]
ClearAll[CtrlGetValue]
ClearAll[CtrlSetValue]
ClearAll[CtrlSignalValue]
ClearAll[GetAllCtrls]
ClearAll[FindCtrl]
ClearAll[GetAllGObjs]
ClearAll[FindGObj]
ClearAll[CtrlHandlerDiagram]
ClearAll[CtrlHandlerNode]
ClearAll[Peak]
ClearAll[Env]

Begin["`Private`"]

(*resv default to be True for LabVIEW 2011*)
LoadVI[viname_String,option_Integer:16,resv_Symbol:False]:=Module[{vipath,r},
vipath=If[StringLength@viname>3&&StringTake[viname,-3]==".vi"&&!StringFreeQ[viname,"\\"|"/"],viname,VIDir<>viname<>".vi"];
r=AppCls@GetVIReference[vipath,"",resv,option];
If[r=!=$Failed,LoadVI[viname]=r];
r
];
(* ReleaseNETObject/@DownValues[LoadVI][[1;;-2,2]] *)

MakeAndCastNETObject[obj_Integer,type_]:=NETLink`CastNETObject[
NETLink`MakeNETObject[obj,"System.UInt32"],type];

MakeAndCastNETObject[obj_,type_]:=Module[{r=obj},
If[!NETLink`NETObjectQ[r],r=NETLink`MakeNETObject[r]];
If[r===$Failed,obj,
If[NETLink`InstanceOf[r,"System.__ComObject"],r,NETLink`CastNETObject[r,type]]]
];

CallVI[vi_?NETLink`NETObjectQ,paramNames_List,paramVals_List]:=Module[{param1,param2,r},
NETLink`BeginNETBlock[];
param1=NETLink`CastNETObject[NETLink`MakeNETObject[paramNames],"object"];
param2=NETLink`ReturnAsNETObject[MakeAndCastNETObject[MakeAndCastNETObject[#,"object"]&/@ paramVals,"object"]];
vi@Call[param1,param2];
r=NETLink`NETObjectToExpression[param2];
NETLink`EndNETBlock[];
r
];
CallVI[viname_String,paramNames_List,paramVals_List]:=CallVI[LoadVI[viname],paramNames,paramVals];

CurrentTimeString[]:=CallVI["CurrentTimeString",{"date/time string"},{""}][[1]];

CtrlGetValue[ctrl_Integer]:=CallVI["CtrlGetValue",{"reference","variant"},{ctrl,""}][[-1]];

CtrlSetValue[ctrl_Integer,variant_]:=CallVI["CtrlSetValue",{"reference","variant"},{ctrl,variant}][[-1]];

CtrlSignalValue[ctrl_Integer,variant_]:=CallVI["CtrlSignalValue",{"reference","variant"},{ctrl,variant}][[-1]];

GetAllCtrls[vi_?NETLink`NETObjectQ,prefix_:""]:=Association[Rule@@#&/@(CallVI["GetAllCtrls",{"VI","Prefix","Ctrls"},{vi,prefix,""}][[-1]])];
GetAllCtrls[viname_String,prefix_:""]:=GetAllCtrls[LoadVI[viname],prefix];

FindCtrl[vi_?NETLink`NETObjectQ,name_String]:=CallVI["FindCtrl",{"VI","Name","Ctrl"},{vi,name,""}][[-1]];
FindCtrl[viname_String,name_String]:=FindCtrl[LoadVI[viname],name];

GetAllGObjs[vi_?NETLink`NETObjectQ,prefix_:""]:=Association[Rule@@#&/@(CallVI["GetAllGObjs",{"VI","Prefix","GObjs"},{vi,prefix,""}][[-1]])];
GetAllGObjs[viname_String,prefix_:""]:=GetAllGObjs[LoadVI[viname],prefix];

FindGObj[vi_?NETLink`NETObjectQ,name_String]:=CallVI["FindGObj",{"VI","Name","GObj"},{vi,name,""}][[-1]];
FindGObj[viname_String,name_String]:=FindGObj[LoadVI[viname],name];

CtrlHandlerDiagram[structure_Integer,ctrl_Integer,type_Integer]:=CallVI["CtrlHandlerDiagram",
{"Structure","Ctrl","Type","Diagram"},{structure,ctrl,type,0}][[-1]];

CtrlHandlerNode[diagram_Integer,name_String,ctrl_Integer,type_Integer,data_:"Mathematica"]:=(CallVI["CtrlHandlerNode.Mathematica",
{"Diagram","Name","Ctrl","Type","Data"},{diagram,name,ctrl,type,data}];);

Peak[data_List,fitfunc_String]:=CallVI["Peak",{"2d Data","Fitting Function","Peak Center","Peak Width","Peak Height"},{Transpose[data],fitfunc,0,0,0}][[-3;;-1]];

Env[name_String]:=Module[{value,names,values},
{value,names,values}=CallVI["Env",{"Name","Value Out","names","values"},{name,"","",""}][[2;;-1]];
If[Length[names]==0,value,
{value,Rule@@#&/@Transpose[{names,values}]}
]
];

Env[name_String,value_]:=(CallVI["Env",{"Name","Value In"},{name,value}];);

If[`Inited===True,
NETLink`ReleaseNETObject[AppCls]; 
ClearAll[AppCls];
AppCls=NETLink`NETNew["LabVIEW.ApplicationClass"],
`Inited=True;
AppCls=NETLink`NETNew["LabVIEW.ApplicationClass"]
];

End[];

EndPackage[];

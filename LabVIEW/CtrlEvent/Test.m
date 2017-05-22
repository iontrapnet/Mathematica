(* ::Package:: *)

SetDirectory@"D:\\GitHub\\iontrapnet\\Mathematica\\LabVIEW\\CtrlEvent";
<<"..\\LabVIEW.m"

ctrls = GetAllCtrls@FileNameJoin@{Directory[],"Test.Mathematica.vi"};
Print[ctrls];

ClearAll[$Event];
$Event["Path","Value Change"]:=CtrlSetValue[ctrls@"Content",CtrlGetValue@ctrls@"Path"];

ClearAll[Event];
Event[name_String,event_String]:=Module[{},
Print[name->event];
$Event[name,event];
];

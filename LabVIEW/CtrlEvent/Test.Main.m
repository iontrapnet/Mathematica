(* ::Package:: *)

SetDirectory@"D:\\GitHub\\iontrapnet\\Mathematica\\LabVIEW\\CtrlEvent";
<<"..\\LabVIEW.m"

<<"CtrlEvent.m"
BindEvent[ctrlName_String,eventName_String]:=Module[{ctrl,event,diagram},
ctrl = ctrls[ctrlName];
event = CtrlEvent[eventName];
diagram = CtrlHandlerDiagram[structure, ctrl, event];
CtrlHandlerNode[diagram, ctrlName, ctrl, event];
];

vi = LoadVI[FileNameJoin@{Directory[],"Test.Mathematica.vi"},16,False];
vi@FPWinOpen = True;
vi@Revert[];
ctrls = GetAllCtrls@vi;
gobjs = GetAllGObjs@vi;
structure = gobjs["Flat Sequence Structure/1/While Loop/Event Structure"];

BindEvent["Path", "Value Change"];

vi@Run[True];

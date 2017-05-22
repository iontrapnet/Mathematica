import sys,os
sys.path.append(os.path.realpath('..'))

from pyLabVIEW import *

def BindEvent(name, event):
    global ctrls,structure
    ctrl = ctrls[name]
    event = CtrlEvent[event]
    diagram = CtrlHandlerDiagram(structure,ctrl,event)
    CtrlHandlerNode(diagram,name,ctrl,event)
    
if __name__ == '__main__':
    import CtrlEvent
    vi = LoadVI(os.path.realpath('.') + '/Test.Python.vi',16,False)
    vi.FPWinOpen = True
    vi.Revert()
    ctrls = GetAllCtrls(vi)
    gobjs = GetAllGObjs(vi)
    structure = gobjs['Flat Sequence Structure/1/While Loop/Event Structure']
    
    BindEvent('Path','Value Change')
    
    vi.Run(True)
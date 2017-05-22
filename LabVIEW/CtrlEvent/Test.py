import sys,os
#sys.path.append(os.path.realpath('..'))

#from pyLabVIEW import *

#ctrls = GetAllCtrls(os.path.realpath('.') + '/Test.Python.vi')
#print(ctrls)

def Event(name,event):
    print(name,event)
    if name == 'Path' and event == 'Value Change':
        #CtrlSetValue(ctrls['Content'],CtrlGetValue(ctrls['Path']))
        os.system('notepad')

if __name__ == '__main__':
    Event('Path','Value Change')

strs = \
'''
Null
Timeout
Annotation Menu Selection
Annotation Menu Selection?
App Instance Close
App Instance Close?
Autoscale Range Change
Bookmark Info Change
Cell Edit
Cell Edit?
Cursor Grab
Cursor Grab?
Cursor Menu Selection
Cursor Menu Selection?
Cursor Move
Cursor Release
Data Change
Direction Change
Display State Change
Drag Ended
Drag Enter
Drag Leave
Drag Over
Drag Source Update
Drag Starting
Drag Starting?
Drop
Exec State Change
Key Down
Key Down?
Key Repeat
Key Repeat?
Key Up
Listbox Double Click
Menu Activation?
Menu Selection (App)
Menu Selection? (App)
Menu Selection (User)
Mouse Down
Mouse Down?
Mouse Enter
Mouse Leave
Mouse Move
Mouse Up
Mouse Wheel
NI Security User Change (App)
Pane Size
Panel Close
Panel Close?
Panel Resize
Plot Attribute Change
Scale Range Change
Shortcut Menu Activation?
Shortcut Menu Selection (App)
Shortcut Menu Selection? (App)
Shortcut Menu Selection (User)
Tree Double Click
Tree Drag
Tree Drag?
Tree Drop
Tree Drop?
Tree Item Close
Tree Item Close?
Tree Item Open
Tree Item Open?
User Event
Value Change
'''.strip().split('\n')
       
class ModModule(object):
    def __init__(self, globals):
        self.__dict__ = globals
        import sys
        sys.modules[self.__name__] = self
    def __getitem__(self, name):
        return self.__dict__[name]

doc = ''
for i in xrange(len(strs)):
    doc += strs[i] + ' = ' + str(i) + '\n'
dict = {'__name__':'CtrlEvent','__doc__':doc}
for i in xrange(len(strs)):
    dict[strs[i]] = i
ModModule(dict)
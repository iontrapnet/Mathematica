from mathlink_h import ffi, ml

from fractions import Fraction

#class Symbol(str):
#    def __repr__(self):
#        return self
        
class Expr(tuple):
    def __str__(self):
        head = self[0]
        #listq = type(head) == Symbol and head == 'List'
        listq = head == 'List'
        if listq:
            r = '{'
        else:
            r = str(head) + '['
        if len(self) > 1:
            r += str(self[1])
            for i in self[2:]:
                r += ', ' + str(i)
        return r + ('}' if listq else ']')
        
class PythonLink(object):
    env = ml.MLInitialize(ffi.cast('void*', 0))

    def deinit():
        ml.MLDeinitialize(PythonLink.env)
            
    def __init__(self):
        pass
    
    def install(self):
        err = ffi.new('int[1]', (0,))
        mldir = br'C:\Program Files\Wolfram Research\Mathematica\11.0'
        mlarg = b"-linklaunch -linkname '" + mldir + br"\math.exe'"
        self.mlp = ml.MLOpenString(self.env, mlarg, err)
    
    def uninstall(self):
        ml.MLClose(self.mlp)
    
    def get_error(self):
        r = ml.MLErrorMessage(self.mlp)
        r = b'"' + ffi.string(r) + b'"'
        r = r.decode('utf-8')
        ml.MLClearError(self.mlp)
        ml.MLNewPacket(self.mlp)
        return Expr(('Error', r))
    
    def get_packet(self):
        waitResult = ml.MLWaitForLinkActivity(self.mlp)
        print('waitResult = ',waitResult)
        if not waitResult:
            return 0
        pkt = ml.MLNextPacket(self.mlp)
        print('pkt = ',pkt)
        return pkt
    
    def get_expr(self):
        t = ml.MLGetNext(self.mlp)
        if t == ml.MLTKINT:
            r = ffi.new('mlint64[1]')
            return r[0] if ml.MLGetInteger64(self.mlp, r) else self.get_error()
        elif t == ml.MLTKREAL:
            r = ffi.new('double[1]')
            ml.GetReal64(self.mlp, r)
            return r[0]
        elif t == ml.MLTKSYM:
            bufp = ffi.new('const char*[1]')
            ml.MLGetSymbol(self.mlp, bufp)
            r = ffi.string(bufp[0])
            ml.MLReleaseString(self.mlp, bufp[0])
            #return Symbol(r)
            return r.decode('utf-8')
        elif t == ml.MLTKSTR:
            bufp = ffi.new('const unsigned char*[1]')
            size = ffi.new('int[1]')
            ml.MLGetByteString(self.mlp, bufp, size, 0)
            r = b'"' + ffi.string(bufp[0],size[0]) + b'"'
            ml.MLReleaseByteString(self.mlp, bufp[0], size[0])
            return r.decode('utf-8')
        elif t == ml.MLTKFUNC:
            n = ffi.new('int[1]')
            ml.MLGetArgCount(self.mlp, n)
            n = n[0]
            return Expr(tuple(self.get_expr() for i in range(n+1)))
    
    def put_expr(self, expr):
        if type(expr) == Expr:
            head = expr[0]
            if type(head) == str:
                ml.MLPutFunction(self.mlp, head.encode('utf-8'), len(expr) - 1)
            else:
                ml.MLPutNext(self.mlp, ml.MLTKFUNC)
                ml.MLPutArgCount(self.mlp, len(expr) - 1)
                self.put_expr(head)
            for i in expr[1:]:
                self.put_expr(i)
        else:
            t = type(expr)
            if t == str:
                if expr[0] == '"':
                    expr = expr[1:-1].encode('utf-8')
                    ml.MLPutByteString(self.mlp, expr, len(expr))
                elif expr.isidentifier():
                    ml.MLPutSymbol(self.mlp, expr)
                else:
                    expr = expr.encode('utf-8')
                    ml.MLPutByteString(mlp, expr, len(expr))
            elif t == int:
                ml.MLPutInteger64(self.mlp, expr)
            elif t == float:
                ml.MLPutReal64(self.mlp, expr)
            elif t == NoneType:
                ml.MLPutSymbol(self.mlp, 'Null')
            else:
                key = str(expr)
                #slot(key, expr)
                #if t == 'function' then
                #    ml.MLPutFunction(mlp, 'PyFunction', 1)
                #elseif t == 'table' then
                #    ml.MLPutFunction(mlp, 'PyTable', 1)
                #end
                ml.MLPutString(self.mlp, key)
    
    defs = tuple()
    def answer(self):
        pkt = self.get_packet()
        if pkt == ml.CALLPKT:
            t = self.get_expr()
            expr = self.get_expr()
            f = defs[t+1]
            if type(f) == tuple:
                f = f[1]
            r = f(expr)
            self.put_expr(r)
            ml.MLEndPacket(self.mlp)
        elif pkt == ml.EVALUATEPKT:
            expr = (self.get_expr(),)
            #expr = leval(expr)
            self.put_expr(expr)
            ml.MLEndPacket(self.mlp)
        elif pkt == ml.RETURNPKT:
            expr = self.get_expr()
            print(expr)
            return expr
        else:
            print(self.get_expr())
        return pkt != 0

link = PythonLink()
link.install()
link.answer()
link.put_expr(Expr(('EvaluatePacket', Expr(('ToExpression', '"100!"')))))
link.answer()
link.put_expr(Expr(('EvaluatePacket', Expr(('ToExpression', '"10!"')))))
link.answer()
link.uninstall()

PythonLink.deinit()
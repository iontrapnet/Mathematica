from fractions import Fraction
import mathlink
e = mathlink.env()
link = e.open('-linkcreate -linkname hehe')

from fractions import Fraction

class Symbol(str):
    def __repr__(self):
        return self

#List = Symbol('List')

class Expr(tuple):
    def __repr__(self):
        head = self[0]
        listq = type(head) == Symbol and head == 'List'
        if listq:
            r = '['
        else:
            r = head.__repr__() + '('
        if len(self) > 1:
            r += self[1].__repr__()
            for i in self[2:]:
                r += ', ' + i.__repr__()
        return r + (']' if listq else ')')
        
def getreal(self):
    t = self.gettype()
    if t == mathlink.MLTKINT:
        return self.getlong()
    elif t == mathlink.MLTKREAL:
        return self.getfloat()  
    elif t == mathlink.MLTKFUNC:    
        f,n = self.getfunction()
        if f == 'Rational':
            return Fraction(self.getlong(), self.getlong())
        else:
            raise 'real number expected!'
          
def getexpr(self):
    t = self.gettype()
    if t == mathlink.MLTKINT:
        return self.getlong()
    elif t == mathlink.MLTKREAL:
        return self.getfloat()
    elif t == mathlink.MLTKSYM:
        return Symbol(self.getsymbol())
    elif t == mathlink.MLTKSTR:
        return self.getstring()
    elif t == mathlink.MLTKFUNC:
        #f,n = self.getfunction()
        n = self.getargcount()
        self.getnext()
        f = getexpr(self)
        if f == 'Rational':
            return Fraction(self.getlong(), self.getlong())
        elif f == 'Complex':
            return complex(getreal(self), getreal(self))
        else:
            return Expr((f,) + tuple(getexpr(self) for i in xrange(n)))

while True:
    print(getexpr(link))
            

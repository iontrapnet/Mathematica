mmadir='C:\Program Files\Wolfram Research\Mathematica\11.0';

addpath([mmadir '\SystemFiles\Libraries\Windows-x86-64']);
mma(['-linklaunch -linkname ''' mmadir '\math''']);

mma('$Version')
mma('N[EulerGamma,40]')
mma('ToString', 'Integrate[Log[x]^(3/2),x]')
mma('ToString', 'InputForm', 'Integrate[Log[x]^(3/2),x]')
mma({'$' 'hilbert' hilb(20)})
mma('ToString', '{Dimensions[hilbert],Det[hilbert]}')
mma('exactHilbert = Table[1/(i+j-1),{i,20},{j,20}];');
mma('ToString', 'Det[exactHilbert]')
mma('ToString', 'N[Det[exactHilbert], 40]')
mma('invHilbert = Inverse[hilbert];')
hilbert=mma('$', 'invHilbert');
diag(hilbert)
disp('Passing and retrieving a scalar')
mma('a=2')
b=3;
mma({'$' 'b' b})
mma('b')
aa=mma('$', '{a}')


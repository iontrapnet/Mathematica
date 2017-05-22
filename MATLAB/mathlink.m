function mathlink()
    load();
    %deinit();
    init();
    %evaluate({'foo', {'Integrate', 'x', 'x'}, int32(3), '"y"'});
    %get_answer();
    %evaluate('foo[Integrate[x,x],3,"y"]');
    %get_answer();
    evaluate({'List' [1 2 3 3 4 5]});
    get_answer();
end

function load()
    global mllib MLTK PKT;
    mllib = 'ml64i4';
    %loadlibrary([mllib '.dll'], 'mathlink.lua.h');
    %loadlibrary([mllib '.dll'], 'mathlink.lua.h', 'mfilename', mllib);
    warning off MATLAB:loadlibrary:TypeNotFound;
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure;
    [notfound,warnings] = loadlibrary([mllib '.dll'], eval(['@' mllib]));
    [methodinfo,structs,enuminfo,ThunkLibName] = eval(mllib);
    MLTK = enuminfo.MLTK;
    PKT = enuminfo.PKT;
end

function init()
    global mllib mlenv mldir mlp;
    mlenv = calllib(mllib, 'MLInitialize', libpointer);
    mldir = 'D:\Program Files\Wolfram Research\Mathematica\11.0\';
    err = libpointer('int32Ptr', 0);
    mlp = calllib(mllib, 'MLOpenString', mlenv, ['-linklaunch -linkname ''' mldir 'math.exe -mathlink'''], err);
    disp(['err = ' num2str(err.value)]);
    get_answer();
    evaluate([
    'MATLABQ[x_]:=VectorQ[x,NumberQ[N[#]]&]||MatrixQ[x,NumberQ[N[#]]&];'...
    '$[x_?MATLABQ] := MATLABArray[N[x]];'...
    'SetAttributes[$,HoldFirst];'...
    '$[x_,y_] := (x=y;);'...
    ]);
    %'$[x_] := (Message[$::badform];$Failed);'
    %'$::badform = "argument to $ not expressible as a MATLAB array.";'
    get_answer();
end

function deinit()
    global mllib mlenv mlp;
    calllib(mllib, 'MLClose', mlp);
    calllib(mllib, 'MLDeinitialize', mlenv);
end

function evaluate(expr)
    global mllib mlp;
    if isstr(expr)
        expr = {'ToExpression', ['"' expr '"']};
    end
    expr = {'EvaluatePacket', expr};
    put_expr(expr);
    calllib(mllib, 'MLEndPacket', mlp);
end

function put_expr(expr)
    global mllib mlp;
    if iscell(expr)
        head = expr{1};
        len = length(expr);
        if isstr(head)
            calllib(mllib, 'MLPutFunction', mlp, head, len - 1);
        else
            calllib(mllib, 'MLPutNext', mlp, MLTK.MLTKFUNC);
            calllib(mllib, 'MLPutArgCount', mlp, len - 1);
            put_expr(head)
        end
        for i=2:len
            put_expr(expr{i});
        end
    elseif isstr(expr)
        if expr(1) == '"'
            calllib(mllib, 'MLPutString', mlp, expr(2:length(expr)-1));
        else
            calllib(mllib, 'MLPutSymbol', mlp, expr);
        end
    elseif isinteger(expr)
        calllib(mllib, 'MLPutInteger64', mlp, expr);
    elseif isreal(expr)
        dim = size(expr);
        if dim(1) == 1 && dim(2) == 1
            calllib(mllib, 'MLPutReal64', mlp, expr);
        else
            heads = libpointer('stringPtrPtr');
            if dim(1) == 1
                dim = [dim(2)];
            end
            calllib(mllib, 'MLPutReal64Array', mlp, expr', dim, heads, length(dim));
        end
    end
end

function get_answer()
    global mllib mlp PKT;
    waitResult = calllib(mllib, 'MLWaitForLinkActivity', mlp);
    disp(['waitResult = ' num2str(waitResult)]);
    if ~waitResult
        return
    end
    pkt = calllib(mllib, 'MLNextPacket', mlp);
    if pkt == PKT.INPUTNAMEPKT
        get_expr();
    elseif pkt == PKT.RETURNPKT
        disp(mma2str(get_expr()));
    elseif pkt == PKT.MESSAGEPKT
        get_expr();
        get_expr();
        get_answer();
    elseif pkt == PKT.TEXTPKT
        disp(get_expr());
    else
        disp(['pkt = ' num2str(pkt)]);
    end
end

function r = get_expr()
    global mllib mlp MLTK;
    r = nan;
    t = calllib(mllib, 'MLGetNext', mlp);
    if t == MLTK.MLTKSYM
        buf = libpointer('uint8Ptr');
        bufp = libpointer('uint8PtrPtr', buf);
        len = libpointer('int32Ptr', 0);
        calllib(mllib, 'MLGetByteSymbol', mlp, bufp, len, 0);
        buf.reshape(1, len.value);
        r = char(buf.value);
        calllib(mllib, 'MLReleaseByteSymbol', mlp, buf, len.value);
        return
    elseif t == MLTK.MLTKSTR
        buf = libpointer('uint8Ptr');
        bufp = libpointer('uint8PtrPtr', buf);
        len = libpointer('int32Ptr', 0);
        calllib(mllib, 'MLGetByteString', mlp, bufp, len, 0);
        buf.reshape(1, len.value);
        r = ['"' char(buf.value) '"'];
        calllib(mllib, 'MLReleaseByteString', mlp, buf, len.value);
        return
    elseif t == MLTK.MLTKINT
        bufp = libpointer('int64Ptr', 0);
        calllib(mllib, 'MLGetInteger64', mlp, bufp);
        r = bufp.value;
        return
    elseif t == MLTK.MLTKREAL
        bufp = libpointer('doublePtr', 0);
        calllib(mllib, 'MLGetReal64', mlp, bufp);
        r = bufp.value;
        return
    elseif t == MLTK.MLTKFUNC
        n = libpointer('int32Ptr', 0);
        calllib(mllib, 'MLGetArgCount', mlp, n);
        n = n.value;
        r = {};
        head = get_expr();
        if isstr(head) && strcmp(head, 'MATLABArray')
            buf = libpointer('doublePtr');
            bufp = libpointer('doublePtrPtr', buf);
            dim = libpointer('int32Ptr');
            dimp = libpointer('int32PtrPtr', dim);
            heads = libpointer('int64Ptr');
            headsp = libpointer('int64PtrPtr', heads);
            len = libpointer('int32Ptr', 0);
            calllib(mllib, 'MLGetReal64Array', mlp, bufp, dimp, headsp, len);
            if len.value == 1
                dim.reshape(1, 1);
                buf.reshape(1, dim.value);
                r = buf.value;
            else
                dim.reshape(1, 2);
                dimv = dim.value;
                buf.reshape(dimv(2), dimv(1));
                r = buf.value';
            end
            calllib(mllib, 'MLReleaseReal64Array', mlp, buf, dim, heads, len.value);
        else
            r{1} = head;
            for i=1:n
                r{i+1} = get_expr();
            end
        end
        return
    end
end

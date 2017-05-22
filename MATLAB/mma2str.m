function r = mma2str(expr)
    if iscell(expr)
        r = [mma2str(expr{1}) '['];
        len = length(expr);
        for i=2:len-1
            r = [r mma2str(expr{i}) ','];
        end
        r = [r mma2str(expr{len}) ']'];
        return
    else
        r = num2str(expr);
        return
    end
end
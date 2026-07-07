function lut = makelut(fun, n, varargin)
    [lhs, rhs] = argn(0);

    if rhs < 2 then
        error("makelut: Wrong number of input arguments.");
    end

    if n < 2 then
        error("makelut: n should be a natural number >= 2");
    end

    nq = n^2;
    c = 2^nq;

    lut = zeros(c, 1);

    w = int32(matrix(2.^[nq-1:-1:0], n, n));

    for i = 0:c-1
        idx = bitand(w, uint32(i)) > 0;
        
       // This block directly use inbuilt fun , assign values dynamically
        nargs = length(varargin);             // fun(idx,varargin(1),varargin(2), ....)
        if nargs == 0 then
            lut(i+1) = fun(idx);
        else
            argstr = "idx";
            for j = 1:nargs
                argstr = argstr + ", varargin(" + string(j) + ")";
            end
            execstr("lut(i+1) = fun(" + argstr + ");");
        end
    end
endfunction

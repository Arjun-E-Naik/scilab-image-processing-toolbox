function A = applylut(BW, LUT)
    [lhs, rhs] = argn(0);
    if rhs <> 2 then
        error("applylut: arguments must be Two..");
    end
    nq = log(length(LUT)) / log(2);
    n = sqrt(nq);
    if floor(n) <> n then
        error("applylut: LUT length is not as expected.");
    end
    
    // reshape(2.^[nq-1:-1:0], n, n)
    w = matrix(2.^[nq-1:-1:0], n, n);
    
  
    A = LUT(filter2(w, bool2s(BW)) + 1);
endfunction


function y = filter2(b, x, shape)
    [lhs, rhs] = argn(0);
    if rhs < 2 then
        error("filter2: arguments should not be less than 2");
    end
    if rhs < 3 then
        shape = "same";
    end
    [nr, nc] = size(b);
    
    //  conv2 with flipped kernel
    y = conv2(x, b(nr:-1:1, nc:-1:1), shape);
endfunction


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

    // reshape(2.^[nq-1:-1:0], n, n)
    w = int32(matrix(2.^[nq-1:-1:0], n, n));

    for i = 0:c-1
        
        idx = bitand(w, int32(i)) > 0;
        
        nargs = length(varargin);
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

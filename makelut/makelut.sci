function lut = makelut(fun,n,varargin)
    [lhs,rhs] = argn(0);

    if rhs < 2 then
        error("makelut: Wrong number of input arguments.");
    end

    if (n<2) then
        error("makelut: n should be a natural number >= 2");
    end


    nq = n^2 ;
    c = 2^nq;

    lut = zeros(c,1);

    w = int32(matrix(2.^[nq-1:-1:0],n,n)); // reshape function in octave

    for i = 0:c-1
        idx = bitand(uint32(w),uint32(i)*ones(w)) > 0; //same function in octave
        lut(i+1) = feval(fun,idx,varargin(:));
    end
    
endfunction

function retval = feval(fun, idx, varargin)

    nargs = length(varargin);

    select nargs
    case 0 then
        retval = fun(idx);

    case 1 then
        retval = fun(idx, varargin(1));

    case 2 then
        retval = fun(idx, varargin(1), varargin(2));

    case 3 then
        retval = fun(idx, varargin(1), varargin(2), varargin(3));

    otherwise
        error("feval: too many arguments");
    end

endfunction

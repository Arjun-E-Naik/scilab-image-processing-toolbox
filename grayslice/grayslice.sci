exec("im2uint16.sci",-1);

function sliced = grayslice(I, n)

    
    [lhs, rhs] = argn(0);
    
    if rhs < 1 | rhs > 2 then
        error("grayslice: Wrong number of input arguments.");
    elseif (~isnumeric(n)) then
        error ("grayslice: N and V must be numeric");
    end
        
    
    if rhs == 1 then
        n = 10;
    end
    

    if typeof(I) == "int16" then
        I = im2uint16(I);
    end

    if isscalar(n) & n >= 1 then
        n = double(n);
        v = (1:(n-1)) ./ n;

        v = imcast(v,class(I));

    elseif (isvector(n) & ~isscalar(n)) | (isscalar(n) & n > 0 & n < 1) then
        v = gsort(n(:), 'g', 'i'); 
        n = length(v) + 1;
        
        if type(I) == 1 then // float/double
            imax = max(I(:));
            imin = min(I(:));
            v(v < imin) = imin;
            v(v > imax) = imax;
        end
    else
        if isscalar(n) & n <= 0 then
            error("grayslice: N must be a positive number");
        end
        error("grayslice: N and V must be a numeric scalar and vector");
    end

    I_d = double(I);
    v_d = double(v);
    sliced_tmp = zeros(I_d);
    
    // for lookup funcction
    for idx = 1:length(v_d)
        sliced_tmp(I_d >= v_d(idx)) = idx;
    end

    if n < 256 then
        sliced_tmp = uint8(sliced_tmp);
    else
        sliced_tmp = sliced_tmp + 1; 
    end

    sliced = sliced_tmp;
endfunction

function cls = class(x)
    t = type(x);
    select t
    case 1 then cls = "double";
    case 4 then cls = "logical";
    case 5 then cls = "sparse";
    case 8 then
        it = inttype(x);
        select it
        case 11 then cls = "uint8";
        case 12 then cls = "uint16";
        case 13 then cls = "uint32";
        case 14 then cls = "uint64";
        case 2 then cls = "int16";
        case 4 then cls = "int32";
        case 8 then cls = "int64";
        case 1 then cls = "int8";
        else
            cls = "unknown_integer";
        end
    case 10 then cls = "string";
    else
        cls = "unknown";
    end
endfunction


function result = isfloat(x)
    result = (type(x) == 1);
endfunction

function result = isscalar(x)
    result = (size(x, 1) == 1 & size(x, 2) == 1);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction
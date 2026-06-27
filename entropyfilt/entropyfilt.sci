
exec("padarray.sci",-1);
exec("imhist.sci",-1);
exec("__spatial_filtering__.sci",-1);

function retval = entropyfilt(I,varargin)
    
    [lhs, rhs] = argn(0);

    if (rhs == 0) then
        error("entropyfilt: not enough input arguments");
    end

    if (~isnumeric(I)) then
        error("entropyfilt: I must be numeric");
    end

    if (rhs >= 2) then
        domain = varargin(1);
    else
        domain = ones(9, 9) == 1; 
    end

    if (~isnumeric(domain) & ~islogical(domain)) then
        error("entropyfilt: DOMAIN must be a logical matrix");
    end

    domain = (domain <> 0);

    if (islogical(I)) then
        nbins = 2;
    else
        nbins = 256;
    end

    select class(I)
    case {"double", "single", "int16", "int32", "int64", "uint16", "uint32", "uint64"} then

        I = im2uint8(I);
    case {"logical", "int8", "uint8"} then
        // ## Do nothing
    else
        error("entropyfilt: cannot handle images of class ''%s''", class(I));
    end

    pad = floor(size(domain) / 2);

    if (rhs >= 3) then
        padding = varargin(2);
    else
        padding = "symmetric";
    end


    
    I = padarray(I, pad, padding);



    even = (round(size(domain) / 2) == size(domain) / 2);

    idx = list();
    for k = 1:ndims(I)
        idx(k) = (even(k) + 1):size(I, k);
    end


    // For 2D images:
    if (ndims(I) == 2) then
        I = I(idx(1), idx(2));
    elseif (ndims(I) == 3) then
        I = I(idx(1), idx(2), idx(3));
    else
        error("entropyfilt: only 2D and 3D images supported");
    end


    retval = __spatial_filtering__(I, domain, "entropy", zeros(size(domain)), nbins);
endfunction

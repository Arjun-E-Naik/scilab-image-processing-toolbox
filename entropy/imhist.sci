function [varargout] = imhist(img, b)

    indexed = %f;

    [lhs, rhs] = argn();

    if (rhs < 1 | rhs > 2) then
        error("imhist: wrong number of arguments.");
    elseif (rhs == 1) then
        if (islogical(img)) then
            b = 2;
        else
            b = 256;
        end
    elseif (rhs == 2) then
        if (iscolormap(b)) then
            if (~isind(img)) then
                error("imhist: second argument is a colormap but first argument is not an indexed image.");
            end
            indexed = %t;

            
            if ((isfloat(img) & max(double(img(:))) > size(b, 1)) | ..
                (isinteger(img) & max(double(img(:))) > size(b, 1) - 1)) then
                warning("imhist: largest index in image exceeds length of colormap.");
            end
        elseif (isnumeric(b) & isscalar(b) & fix(b) == b & b > 0) then
            if (islogical(img) & b ~= 2) then
                error("imhist: there can only be 2 bins when input image is binary")
            end
        else
            error("imhist: second argument must be a positive integer scalar or a colormap");
        end
    end

  
    if (indexed) then
        if (isinteger(img)) then
            bins = 0:size(b, 1) - 1;
        else
            bins = 1:size(b, 1);
        end
    else
        if (isinteger(img)) then
            bins = linspace(intmin(class(img)), intmax(class(img)), b);
        elseif (islogical(img)) then
            bins = 0:1;
        else
            bins = linspace(0, 1, b);
        end

        if (~islogical(img)) then
            bins_adjustment = ((bins(2) - bins(1)) / 2);
            bins = bins - bins_adjustment;
        end

        bins = bins';

        
        if (isfloat(img) & min(double(img(:))) < 0) then
            img(img < 0) = 0;
        end

       
        if (max(double(img(:))) > bins($)) then
            if (fix(bins($)) ~= bins($)) then
                img = double(img);
            end
            img(img > bins($)) = bins($);
        end
    end

    
    [nn] = histc_compat(double(img(:)), bins);

    if (~indexed & ~islogical(img)) then
        bins = bins + bins_adjustment;
    end

    if (lhs ~= 0) then
        varargout(1) = nn;
        varargout(2) = bins;
    else
        stem(bins, nn);
        e = gce();
        if (typeof(e) == "Compound") then
            e.children(1).mark_mode = "off";
        end

        a = gca();
        a.data_bounds = [bins(1), 0; bins($), max(nn) * 1.1];

        a.box = "off";

        ylimit = round(median(nn) * 10);
        if (a.data_bounds(2, 2) > ylimit & ylimit ~= 0) then
            a.data_bounds(2, 2) = ylimit;
        end

        if (indexed) then
            colormap(b);
        else
            colormap(graycolormap(b));
        end

        call_colorbar()
    end
endfunction


function call_colorbar()
    colorbar();
endfunction

function nn = histc_compat(data, edges)
    // edges: vector of bin edges [e1, e2, ..., eN]
    // Returns: nn — column vector of length N where:
    //   nn(i) for i=1:N-1: count of values in [edges(i), edges(i+1))
    //   nn(N): count of values exactly equal to edges(N)

    n_edges = length(edges);
    nn = zeros(n_edges, 1);

    if (n_edges == 0) then
        return;
    end

    if (n_edges == 1) then
        nn(1) = sum(data == edges(1));
        return;
    end

    for i = 1:(n_edges - 1)
        // Standard bin: edges(i) <= data < edges(i+1)
        nn(i) = sum(data >= edges(i) & data < edges(i + 1));
    end
    nn(n_edges) = sum(data == edges(n_edges));
endfunction


function result = islogical(x)
    result = (type(x) == 4);
endfunction

function result = isinteger(x)
    result = (type(x) == 8);
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

function result = issparse(x)
    result = (type(x) == 5);
endfunction

function result = iscolormap(x)
    [nr, nc] = size(x);
    result = (nc == 3 & nr > 0);
    if (result) then
        result = (min(x) >= 0 & max(x) <= 1);
    end
endfunction

function bool = isind(img)
    bool = %f;
    im_is_valid = (or(type(img) == [1, 5, 8]) | type(img) == 4) & ndims(img) >= 2;
    if (im_is_valid & ndims(img) < 5 & size(img, 3) == 1) then
        if (type(img) == 1) then
            bool = and((img == floor(img)) & (img > 0), "*");
        elseif (or(inttype(img) == [11, 12])) then
            bool = %t;
        end
    end
endfunction

function m = intmin(cls)
    select cls
    case "uint8" then m = 0;
    case "uint16" then m = 0;
    case "int8" then m = -128;
    case "int16" then m = -32768;
    case "int32" then m = -2147483648;
    case "uint32" then m = 0;
    case "int64" then m = -9223372036854775808;
    case "uint64" then m = 0;
    else
        error("intmin: unsupported class " + cls);
    end
endfunction

function m = intmax(cls)
    select cls
    case "uint8" then m = 255;
    case "uint16" then m = 65535;
    case "int8" then m = 127;
    case "int16" then m = 32767;
    case "int32" then m = 2147483647;
    case "uint32" then m = 4294967295;
    case "int64" then m = 9223372036854775807;
    case "uint64" then m = 18446744073709551615;
    else
        error("intmax: unsupported class " + cls);
    end
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

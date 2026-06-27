
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
            // ## avoid it if we can
            if (fix(bins($)) ~= bins($)) then
                img = double(img);
            end
            img(img > bins($)) = bins($);
        end
    end

    [nn] = histc_compat(img(:), bins);

    if (~indexed & ~islogical(img)) then
        bins = bins + bins_adjustment;
    end


    if (lhs ~= 0) then
        varargout(1) = nn;
        varargout(2) = bins;
    else

        stem(bins, nn);
        // Remove markers manually in Scilab
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

// -------------- Helper function ------------

function nn = histc_compat(data, edges)
    // Compatibility function for Octave's histc
    n_bins = length(edges);
    nn = zeros(n_bins, 1);

    if (n_bins == 1) then
        nn(1) = length(data);
        return;
    end

    for i = 1:(n_bins - 1)
        if (i == n_bins - 1) then
            nn(i) = sum(data >= edges(i) & data <= edges(i + 1));
        else
            nn(i) = sum(data >= edges(i) & data < edges(i + 1));
        end
    end

    nn = zeros(n_bins, 1);

    for i = 1:(n_bins - 1)
        nn(i) = sum(data >= edges(i) & data < edges(i + 1));
    end


    nn(n_bins) = sum(data == edges(n_bins));
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
        // Integer types
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


// ============================================================================
// IMCAST FUNCTION
// ============================================================================

function imout = imcast(img, outcls, varargin)
    [lhs, rhs] = argn();

    if (rhs < 2 || rhs > 3) then
        error("imcast: wrong number of arguments.");
    end
    
    is_indexed_mode = %f;
    if (rhs == 3) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("imcast: third argument must be the string ""indexed""");
        end
        is_indexed_mode = %t;
    end

    outcls = convstr(outcls, "l");

    incls_type = type(img);
    incls_str = "";
    
    if incls_type == 1 then
        incls_str = "double"; 
    elseif incls_type == 4 then
        incls_str = "logical"; 
    elseif incls_type == 8 then
        select inttype(img)
        case 11 then incls_str = "uint8";
        case 12 then incls_str = "uint16";
        case 2 then incls_str = "int16";
        else
            error("imcast: unsupported integer input class.");
        end
    else
        error("imcast: unknown image class type.");
    end

    if is_indexed_mode then
        if ~isind(img) then
            error("imcast: input should have been an indexed image but it is not.");
        end

        if (outcls == "single" || outcls == "double") then
            if incls_type == 8 then
                imout = double(img) + 1; 
            else
                imout = double(img);
            end
        else
            select outcls
            case "uint8" then target_max = 255;
            case "uint16" then target_max = 65535;
            case "int16" then target_max = 32767;
            else
                error("imcast: unsupported integer type " + outcls);
            end

            if incls_type == 8 then
                if max(double(img)) > target_max then
                    error(msprintf("imcast: IMG has too many colours %d for the range of values in %s", max(double(img)), outcls));
                end
            elseif incls_type == 1 then
                imax = max(img) - 1;
                if imax > target_max then
                    error(msprintf("imcast: IMG has too many colours %d for the range of values in %s", imax, outcls));
                end
                img = img - 1; 
            end
            
            select outcls
            case "uint8" then imout = uint8(img);
            case "uint16" then imout = uint16(img);
            case "int16" then imout = int16(img);
            end
        end

    else
        problem = %f;
        
        select incls_str
        case "double" then
            select outcls
            case "uint8" then 
                img_clamped = max(0, min(1, img));
                imout = uint8(round(img_clamped * 255));
            case "uint16" then 
                img_clamped = max(0, min(1, img));
                imout = uint16(round(img_clamped * 65535));
            case "int16" then 
                img_clamped = max(0, min(1, img));
                imout = int16(round(img_clamped * 65535 - 32768));
            case "double" then imout = double(img);
            case "single" then imout = double(img); 
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "uint8" then
            select outcls
            case "double" then imout = double(img) / 255;
            case "uint8" then imout = img; 
            case "single" then imout = double(img) / 255;
            case "uint16" then imout = uint16(img) * 257; 
            case "int16" then imout = int16(double(img) * 257 - 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "uint16" then
            select outcls
            case "double" then imout = double(img) / 65535;
            case "single" then imout = double(img) / 65535;
            case "uint8" then imout = img;
            case "int16" then imout = int16(double(img) - 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "logical" then
            select outcls
            case "double" then imout = double(img);
            case "single" then imout = double(img);
            case "uint8" then 
                imout = zeros(img); 
                imout(img) = 255;
                imout = uint8(imout);
            case "uint16" then 
                imout = zeros(img); 
                imout(img) = 65535;
                imout = uint16(imout);
            case "int16" then 
                imout = ones(img) * -32768; 
                imout(img) = 32767;
                imout = int16(imout);
            case "logical" then imout = img; 
            else problem = %t;
            end

        case "int16" then
            select outcls
            case "double" then imout = (double(img) + 32768) / 65535;
            case "single" then imout = (double(img) + 32768) / 65535;
            case "uint8" then imout = uint8((double(img) + 32768) / 257);
            case "uint16" then imout = uint16(double(img) + 32768);
            case "logical" then imout = (img <> 0);
            case "int16" then imout = img;
            else problem = %t;
            end
        end
        
        if (problem) then
            error("imcast: unsupported TYPE """ + outcls + """");
        end
    end
endfunction


// ============================================================================
// IM2UINT8 FUNCTION
// ============================================================================

function imout = im2uint8(img, varargin)
    [lhs, rhs] = argn();

    if (rhs < 1 || rhs > 2) then
        error("im2uint8: usage: im2uint8 (img) or im2uint8 (img, ""indexed"")");
    end

    if (rhs == 2) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("im2uint8: second input argument must be the string ""indexed""");
        end
    end

    imout = imcast(img, "uint8", varargin(:));
endfunction

function bool = isind(img)
    bool = %f;
    im_is_valid = (or(type(img) == [1, 5, 8]) || type(img) == 4) && ndims(img) >= 2;
    if (im_is_valid && ndims(img) < 5 && size(img, 3) == 1) then
        if (type(img) == 1) then
            bool = and((img == floor(img)) & (img > 0), "*");
        elseif (or(inttype(img) == [11, 12])) then
            bool = %t;
        end
    end
endfunction



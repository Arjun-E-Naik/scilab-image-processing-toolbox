

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

    cls = class(I);
    // FIX: Added int8 to the conversion list
    if (cls == "double" | cls == "single" | cls == "int8" | cls == "int16" | cls == "int32" | cls == "int64" | cls == "uint16" | cls == "uint32" | cls == "uint64") then
        I = im2uint8(I);
    elseif (cls == "logical" | cls == "uint8") then
        // Do nothing
    else
        error("entropyfilt: cannot handle images of class ''%s''", cls);
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

    if (ndims(I) == 2) then
        I = I(idx(1), idx(2));
    elseif (ndims(I) == 3) then
        I = I(idx(1), idx(2), idx(3));
    else
        error("entropyfilt: only 2D and 3D images supported");
    end

    retval = __spatial_filtering__(I, domain, "entropy", zeros(size(domain)), nbins);
endfunction



// IMHIST FUNCTION

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



// HISTC_COMPAT 


function nn = histc_compat(data, edges)
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
        nn(i) = sum(data >= edges(i) & data < edges(i + 1));
    end

    nn(n_edges) = sum(data == edges(n_edges));
endfunction



// HELPER FUNCTIONS


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



// IMCAST FUNCTION


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
            // FIX: Proper uint16 to uint8 conversion
            case "uint8" then imout = uint8(double(img) / 257);
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


// IM2UINT8 FUNCTION


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


function B = padarray(A, padsize, padval, varargin)
    [lhs, rhs] = argn();
    
    if (rhs < 2) then
        error("padarray: not enough input arguments");
    end
    
    if (rhs < 3) then
        padval = 0;
    end
    
    direction = "both";
    if (rhs >= 4) then
        direction = varargin(1);
    end
    
    if (type(padval) == 10) then
        method = convstr(padval, "l");
        select method
        case "symmetric" then
            B = padarray_symmetric(A, padsize, direction);
        case "replicate" then
            B = padarray_replicate(A, padsize, direction);
        case "circular" then
            B = padarray_circular(A, padsize, direction);
        else
            error("padarray: unknown padding method: " + padval);
        end
    else
        B = padarray_constant(A, padsize, padval, direction);
    end
endfunction


function B = padarray_symmetric(A, padsize, direction)
    [rows, cols] = size(A);
    pr = padsize(1);
    pc = padsize(2);
    
    select convstr(direction, "l")
    case "both" then
        if (pr > 0) then
            top    = A(pr:-1:1, :);              // was: A(pr+1:-1:2, :)
            bottom = A(rows:-1:rows-pr+1, :);     // was: A(rows-1:-1:rows-pr, :)
        else
            top = [];
            bottom = [];
        end
        
        if (pc > 0) then
            left  = A(:, pc:-1:1);                // was: A(:, pc+1:-1:2)
            right = A(:, cols:-1:cols-pc+1);       // was: A(:, cols-1:-1:cols-pc)
        else
            left = [];
            right = [];
        end
        
        if (pr > 0 & pc > 0) then
            topleft     = A(pr:-1:1, pc:-1:1);
            topright    = A(pr:-1:1, cols:-1:cols-pc+1);
            bottomleft  = A(rows:-1:rows-pr+1, pc:-1:1);
            bottomright = A(rows:-1:rows-pr+1, cols:-1:cols-pc+1);
        else
            topleft = [];
            topright = [];
            bottomleft = [];
            bottomright = [];
        end
        
        B = [topleft, top, topright;
             left, A, right;
             bottomleft, bottom, bottomright];
             
    case "pre" then
        if (pr > 0) then
            top = A(pr:-1:1, :);
        else
            top = [];
        end
        if (pc > 0) then
            left = A(:, pc:-1:1);
            topleft = A(pr:-1:1, pc:-1:1);
        else
            left = [];
            topleft = [];
        end
        B = [topleft, top;
             left, A];
             
    case "post" then
        if (pr > 0) then
            bottom = A(rows:-1:rows-pr+1, :);
        else
            bottom = [];
        end
        if (pc > 0) then
            right = A(:, cols:-1:cols-pc+1);
            bottomright = A(rows:-1:rows-pr+1, cols:-1:cols-pc+1);
        else
            right = [];
            bottomright = [];
        end
        B = [A, right;
             bottom, bottomright];
    end
endfunction


function B = padarray_replicate(A, padsize, direction)
    [rows, cols] = size(A);
    pr = padsize(1);
    pc = padsize(2);
    
    select convstr(direction, "l")
    case "both" then
        top = repmat(A(1,:), pr, 1);
        bottom = repmat(A(rows,:), pr, 1);
        left = repmat(A(:,1), 1, pc);
        right = repmat(A(:,cols), 1, pc);
        
        topleft = A(1,1) * ones(pr, pc);
        topright = A(1,cols) * ones(pr, pc);
        bottomleft = A(rows,1) * ones(pr, pc);
        bottomright = A(rows,cols) * ones(pr, pc);
        
        B = [topleft, top, topright;
             left, A, right;
             bottomleft, bottom, bottomright];
             
    case "pre" then
        top = repmat(A(1,:), pr, 1);
        left = repmat(A(:,1), 1, pc);
        topleft = A(1,1) * ones(pr, pc);
        B = [topleft, top;
             left, A];
             
    case "post" then
        bottom = repmat(A(rows,:), pr, 1);
        right = repmat(A(:,cols), 1, pc);
        bottomright = A(rows,cols) * ones(pr, pc);
        B = [A, right;
             bottom, bottomright];
    end
endfunction


function B = padarray_circular(A, padsize, direction)
    [rows, cols] = size(A);
    pr = padsize(1);
    pc = padsize(2);
    
    select convstr(direction, "l")
    case "both" then
        top = A(rows-pr+1:rows, :);
        bottom = A(1:pr, :);
        left = A(:, cols-pc+1:cols);
        right = A(:, 1:pc);
        
        topleft = A(rows-pr+1:rows, cols-pc+1:cols);
        topright = A(rows-pr+1:rows, 1:pc);
        bottomleft = A(1:pr, cols-pc+1:cols);
        bottomright = A(1:pr, 1:pc);
        
        B = [topleft, top, topright;
             left, A, right;
             bottomleft, bottom, bottomright];
    else
        error("padarray_circular: only ''both'' direction supported");
    end
endfunction


function B = padarray_constant(A, padsize, padval, direction)
    [rows, cols] = size(A);
    pr = padsize(1);
    pc = padsize(2);
    
    select convstr(direction, "l")
    case "both" then
        new_rows = rows + 2*pr;
        new_cols = cols + 2*pc;
        B = padval * ones(new_rows, new_cols);
        B(pr+1:pr+rows, pc+1:pc+cols) = A;
    case "pre" then
        new_rows = rows + pr;
        new_cols = cols + pc;
        B = padval * ones(new_rows, new_cols);
        B(pr+1:pr+rows, pc+1:pc+cols) = A;
    case "post" then
        new_rows = rows + pr;
        new_cols = cols + pc;
        B = padval * ones(new_rows, new_cols);
        B(1:rows, 1:cols) = A;
    end
endfunction


// ============================================================================
// __SPATIAL_FILTERING__ — FIXED OUTPUT SIZE
// ============================================================================

function retval = __spatial_filtering__(I, domain, method, dummy, nbins)
    // I is the PADDED (and optionally trimmed) image
    // Output must match ORIGINAL image size
    
    if (method ~= "entropy") then
        error("__spatial_filtering__: only ''entropy'' method supported");
    end
    
    [padded_rows, padded_cols] = size(I);
    [drows, dcols] = size(domain);
    
    // FIX: Use drows/dcols directly instead of 2*pad
    orig_rows = padded_rows - drows + 1;
    orig_cols = padded_cols - dcols + 1;
    
    if (orig_rows < 1 | orig_cols < 1) then
        error("__spatial_filtering__: domain is larger than the image");
    end
    
    // Output: original image size
    retval = zeros(orig_rows, orig_cols);
    
    // Simple sliding window — works for both odd and even domains
    for r = 1:orig_rows
        for c = 1:orig_cols
            nhood = I(r:r+drows-1, c:c+dcols-1);
            nhood = nhood(domain);
            retval(r, c) = entropy_nhood(nhood, nbins);
        end
    end
endfunction


// ============================================================================
// ENTROPY_NHOOD — FIXED (single definition, empty-set guard)
// ============================================================================

function e = entropy_nhood(nhood, nbins)
    // Compute entropy of a neighborhood (1D vector of values)
    
    // Flatten to column vector
    nhood = nhood(:);
    n = length(nhood);
    
    // FIX: Guard against empty neighborhoods (all-zero domain, etc.)
    if (n == 0) then
        e = 0;
        return;
    end
    
    // Compute histogram
    if (islogical(nhood)) then
        // Boolean: count true and false
        p1 = sum(nhood) / n;  // fraction of true
        if (p1 <= 0 | p1 >= 1) then
            e = 0;
            return;
        end
        p0 = 1 - p1;           // fraction of false
        P = [p0; p1];
        P = P(P > 0);  // Remove zeros
    else
        // For uint8: bins are 0:255
        if (nbins == 256) then
            // Fast path for uint8
            counts = zeros(256, 1);
            for k = 1:n
                v = double(nhood(k)) + 1;  // 1-based index
                if (v >= 1 & v <= 256) then
                    counts(v) = counts(v) + 1;
                end
            end
            P = counts(counts > 0);  // Remove zero bins
            if (isempty(P)) then
                e = 0;
                return;
            end
            P = P ./ sum(P);          // Normalize
        else
            // General case for non-uint8 or custom nbins
            min_val = min(double(nhood));
            max_val = max(double(nhood));
            if (min_val == max_val) then
                e = 0;
                return;
            end
            counts = zeros(nbins, 1);
            for k = 1:n
                // Find bin
                v = double(nhood(k));
                bin = min(nbins, max(1, floor((v - min_val) / (max_val - min_val) * nbins) + 1));
                counts(bin) = counts(bin) + 1;
            end
            P = counts(counts > 0);
            if (isempty(P)) then
                e = 0;
                return;
            end
            P = P ./ sum(P);
        end
    end
    
    // Compute entropy: -sum(P .* log2(P))
    e = -sum(P .* log2(P));
endfunction

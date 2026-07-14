function retval = stdfilt(I, varargin)
    [lhs, rhs] = argn(0);


    if (rhs < 1) then
        error("stdfilt: not enough input arguments");
    end


    if (~isimage(I)) then
        error("stdfilt: first input must be a matrix");
    end


    domain  = ones(3, 3);  
    padding = "symmetric";

    if (rhs >= 2) then
        domain = varargin(1);
    end
    if (rhs >= 3) then
        padding = varargin(2);
    end


    if (~isnumeric(domain) & ~islogical(domain)) then
        error("stdfilt: second input argument must be a logical matrix");
    end


    domain = (domain <> 0);


    pad = floor(size(domain) / 2);

    // I = padarray (I, pad, padding, varargin {:});
    pad_args = list(pad, padding);
    if (rhs >= 4) then
        for k = 3:length(varargin)
            pad_args($+1) = varargin(k);
        end
    end
    I = padarray(I, pad_args(:));

    even = (round(size(domain) / 2) == size(domain) / 2);

    idx = list();
    for k = 1:ndims(I)
        idx(k) = (even(k) + 1):size(I, k);
    end

    I = I(idx(:));


    retval = __spatial_filtering__(I, domain, "std", zeros(size(domain)), 0);
endfunction


function retval = __spatial_filtering__(I, domain, method, dummy, nbins)
    if (method ~= "std") then
        error("__spatial_filtering__: unsupported method ''" + method + "''");
    end

    orig_size = size(I);
    domain_double = double(domain);
    domain_flipped = domain_double($:-1:1, $:-1:1);

    N = sum(domain_double);

    if (N <= 1) then
        pad_r = size(domain, 1) - 1;
        pad_c = size(domain, 2) - 1;
        retval = zeros(orig_size(1) - pad_r, orig_size(2) - pad_c);
        return;
    end

    I_double = double(I);

    sum_X  = conv2(I_double, domain_flipped, "valid");
    sum_X2 = conv2(I_double.^2, domain_flipped, "valid");

    variance = (sum_X2 - (sum_X.^2) / N) / (N - 1);
    variance = variance .* bool2s(variance > 0);

    retval = sqrt(variance);
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
            top    = A(pr:-1:1, :);
            bottom = A(rows:-1:rows-pr+1, :);
        else
            top = [];
            bottom = [];
        end

        if (pc > 0) then
            left  = A(:, pc:-1:1);
            right = A(:, cols:-1:cols-pc+1);
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


function result = isimage(x)
    result = isnumeric(x) | islogical(x);
endfunction

function result = islogical(x)
    result = (type(x) == 4);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction

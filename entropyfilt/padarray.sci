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
            top = A(pr+1:-1:2, :);
            bottom = A(rows-1:-1:rows-pr, :);
        else
            top = [];
            bottom = [];
        end
        
        if (pc > 0) then
            left = A(:, pc+1:-1:2);
            right = A(:, cols-1:-1:cols-pc);
        else
            left = [];
            right = [];
        end
        
        if (pr > 0 & pc > 0) then
            topleft = A(pr+1:-1:2, pc+1:-1:2);
            topright = A(pr+1:-1:2, cols-1:-1:cols-pc);
            bottomleft = A(rows-1:-1:rows-pr, pc+1:-1:2);
            bottomright = A(rows-1:-1:rows-pr, cols-1:-1:cols-pc);
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
            top = A(pr+1:-1:2, :);
        else
            top = [];
        end
        if (pc > 0) then
            left = A(:, pc+1:-1:2);
            topleft = A(pr+1:-1:2, pc+1:-1:2);
        else
            left = [];
            topleft = [];
        end
        B = [topleft, top;
             left, A];
             
    case "post" then
        if (pr > 0) then
            bottom = A(rows-1:-1:rows-pr, :);
        else
            bottom = [];
        end
        if (pc > 0) then
            right = A(:, cols-1:-1:cols-pc);
            bottomright = A(rows-1:-1:rows-pr, cols-1:-1:cols-pc);
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

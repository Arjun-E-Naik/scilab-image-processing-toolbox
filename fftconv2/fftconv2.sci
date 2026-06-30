

function Y = fft2(x)
    dims = size(x);
    Y = fft(x, -1, dims(1), 1);
    Y = fft(Y, -1, dims(2), dims(1));
endfunction

function y = ifft2(X)
    dims = size(X);
    y = fft(X, 1, dims(1), 1);
    y = fft(y, 1, dims(2), dims(1));
endfunction

function X = fftconv2 (varargin)
  if (argn(2) < 2)
    error("fftconv2: usage: fftconv2(a, b[, shape]) or fftconv2(v1, v2, a[, shape])");
  end

  nargs = argn(2);
  if (type(varargin(argn(2))) == 10)  
    shape = varargin(argn(2));
    nargs = nargs - 1;
  else
    shape = "full";
  end

  rowcolumn = %f;  
  if (nargs == 2)
    a = varargin(1);
    b = varargin(2);
  elseif (nargs == 3)
    rowcolumn = %t;  
    if (~(isnumeric(varargin(3)) | islogical(varargin(3))))
      error("fftconv2: A must be a numeric or logical array");
    end
    v1      = vec(varargin(1));
    v2      = vec(varargin(2), 2);
    orig_a  = varargin(3);
  else
    error("fftconv2: usage: fftconv2(a, b[, shape]) or fftconv2(v1, v2, a[, shape])");
  end

  if (rowcolumn)
    a = fftconv2 (orig_a, v2);
    b = v1;
  end

  ra = size(a, 1);  
  ca = size(a, 2); 
  rb = size(b, 1);
  cb = size(b, 2);

  A = fft2 (padarray (a, [rb-1 cb-1], "post"));
  B = fft2 (padarray (b, [ra-1 ca-1], "post"));

  X = ifft2(A.*B);

  if (rowcolumn) then

    rb = size(v1, 1);
    ra = size(orig_a, 1);
    cb = size(v2, 2);
    ca = size(orig_a, 2);
  end

  select convstr(shape, "l") 
    case "full"
      // do nothing
    case "same"
      r_top = ceil ((rb + 1) / 2);
      c_top = ceil ((cb + 1) / 2);
      X = X(r_top:r_top + ra - 1, c_top:c_top + ca - 1);
    case "valid"
      X = X(rb:ra, cb:ca);
    else
      error("fftconv2: unknown convolution SHAPE " + shape);
  end

endfunction


function B = padarray(A, padsize, varargin)
    [lhs, rhs] = argn();
    
    if (rhs < 2) then
        error("padarray: not enough input arguments");
    end
    
    
    padval = 0;
    direction = "both";
    
    if (rhs == 3) then
       
        arg3 = varargin(1);
        if (type(arg3) == 10) then
            opt = convstr(arg3, "l");
            if (opt == "both" | opt == "pre" | opt == "post") then
                direction = opt;
                padval = 0;
            else
                padval = arg3; 
            end
        else
            padval = arg3;
        end
        
    elseif (rhs >= 4) then
        padval = varargin(1);
        direction = convstr(varargin(2), "l");
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
        // Replicate edge rows/columns
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



function v = vec (x, varargin)

  if (argn(2) < 1)
    error ("vec: usage: vec(x[, dim])");
  end

  v = matrix(x, -1, 1);

  if (argn(2) > 1)
    if (dim == 2)
      v = v';
    end
  end

endfunction


function result = islogical (x)
  result = (type(x) == 4);
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


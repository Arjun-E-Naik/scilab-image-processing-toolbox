


function J = integralImage(I, orientation)

  if (argn(2) < 1 | argn(2) > 2)
    error("Usage: integralImage(img) or integralImage(img, orient)");
  end

  if (argn(2) < 2)
    orientation = "upright";
  end

  if (~isimage(I))
    error("integralImage: first argument should be an image");
  end

  if (typeof(I) <> "constant")
    I = double(I);
  end

  orientation = convstr(orientation, "l");
  if (orientation == "upright")
    J = cumsum(cumsum(I, "c"), "r");
    J = padarray(J, [1 1], 0, "pre");
  elseif (orientation == "rotated")
    if (ndims(I) == 2)
      J = integralImage_rotate_2D(I);
    else
      IR = matrix(I, size(I,1), size(I,2), -1);
      J = zeros(size(IR,1)+1, size(IR,2)+2, size(IR,3));
      for i = 1:size(IR,3)
        J(:,:,i) = integralImage_rotate_2D(IR(:,:,i));
      end
      s = size(I);
      J = matrix(J, [size(J,1) size(J,2) s(3:$)]);
    end
  else
    error("orientation should be upright (default) or rotated");
  end
endfunction

function J = integralImage_rotate_2D(I)
  nr = size(I, 1);     
  nc = size(I, 2);      
  J  = zeros(nr + 1, nc + 2);
  
  J(2, 2:nc+1) = I(1, :);
  s21 = nc + 1;         
  
  for y = 3:(nr + 1)
    y1 = y - 1;
    J(y, 1)    = J(y1, 2);
    J(y, 2:s21) = J(y1, 1:nc) + J(y1, 3:(nc+2)) - J(y-2, 2:s21) + I(y1, :) + I(y-2, :);
    J(y, $)    = J(y1, s21);
  end
endfunction


// helper functions 
function result = isimage(x)
    result = isnumeric(x) | islogical(x);
endfunction

function result = islogical(x)
    result = (type(x) == 4);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
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
        error("padarray_circular: only both direction supported");
    end
endfunction

function B = padarray_constant(A, padsize, padval, direction)
    s = size(A);
    rows = s(1);
    cols = s(2);
    pr = padsize(1);
    pc = padsize(2);
    sz_rest = s(3:$);
    has_rest = ~isempty(sz_rest);

    select convstr(direction, "l")
    case "both" then
        new_rows = rows + 2*pr;
        new_cols = cols + 2*pc;
        r1 = pr + 1;  r2 = pr + rows;
        c1 = pc + 1;  c2 = pc + cols;
    case "pre" then
        new_rows = rows + pr;
        new_cols = cols + pc;
        r1 = pr + 1;  r2 = pr + rows;
        c1 = pc + 1;  c2 = pc + cols;
    case "post" then
        new_rows = rows + pr;
        new_cols = cols + pc;
        r1 = 1;  r2 = rows;
        c1 = 1;  c2 = cols;
    else
        error("padarray_constant: unknown direction: " + direction);
    end

    if ~has_rest then
        
        B = padval * ones(new_rows, new_cols);
        B(r1:r2, c1:c2) = A;
    else
        //N-D case: 
        n_extra = prod(sz_rest);
        A_flat  = matrix(A, rows, cols, n_extra);   

        B_flat = padval * ones(new_rows, new_cols, n_extra);
        for k = 1:n_extra
            slice = padval * ones(new_rows, new_cols);
            slice(r1:r2, c1:c2) = A_flat(:, :, k);   
            B_flat(:, :, k) = slice;                 
        end

        
        B = matrix(B_flat, [new_rows, new_cols, sz_rest]);
    end
endfunction

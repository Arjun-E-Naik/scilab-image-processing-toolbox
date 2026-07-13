

function J = integralImage3(I)

  if (argn(2) <> 1)
    error("integralImage3: incorrect number of arguments");
  end

  if (~isimage(I))
    error("integralImage3: I should be an image");
  end

  if (ndims(I) > 3)
    error("integralImage3: I should be a 3-dimensional image");
  end

  if (typeof(I) <> "constant") then
    if (islogical(I)) then
      I = bool2s(I);
    else
      I = double(I);
    end
  end
// This block handles the 3d matrices and calculates the cumsum
  sz = size(I);
  if (length(sz) < 3) then
    sz = [sz, 1];
  end
  rows   = sz(1);
  cols   = sz(2);
  frames = sz(3);


  dims = [rows, cols, frames];
  d = 1;
  for k = 1:3
    if (dims(k) > 1) then
      d = k;
      break;
    end
  end

  J = cumsum(I, d);   
  J = cumsum(J, 2);
  J = cumsum(J, 3);  

  J = matrix(J, rows, cols, frames);  
  J = padarray_constant(J, [1 1 1], 0,"pre");

endfunction


// ---------- helper functions ----------
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
   
    nd = ndims(A);

    if (length(padsize) < nd) then
        padsize(length(padsize)+1:nd) = 0;
    end

    // sz = size (A);
    sz = size(A);

    if (length(sz) < nd) then
        sz(length(sz)+1:nd) = 1;
    end

    idx = list();


    select convstr(direction, "l")


    case "pre" then
        for i = 1:nd
            idx(i) = (padsize(i)+1):(padsize(i)+sz(i));
            sz(i)  = sz(i) + padsize(i);
        end

    case "post" then
        for i = 1:nd
            idx(i) = 1:sz(i);
            sz(i)  = sz(i) + padsize(i);
        end


    case "both" then
        for i = 1:nd
            idx(i) = (padsize(i)+1):(padsize(i)+sz(i));
            sz(i)  = sz(i) + 2*padsize(i);
        end

    else
        error("padarray_constant: unknown direction: " + direction);
    end

    B = padval * ones(sz);

    idxstr = "";
    for i = 1:nd
        if i > 1 then
            idxstr = idxstr + ",";
        end
        idxstr = idxstr + "idx(" + string(i) + ")";
    end
    execstr("B(" + idxstr + ") = A");
endfunction
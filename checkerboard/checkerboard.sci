function [board] = checkerboard(varargin)
    [lhs, rhs] = argn(0);
    
    // Default side value if not provided
    if rhs > 0 then
        side = varargin(1);
    else
        side = 10;
    end

    //Check SIDE argument
    if rhs > 0 & ~(length(side)==1 & type(side)==1 & side == floor(side) & side >= 0) then
        error("checkerboard: SIDE must be a non-negative integer");
    end

    //Parse arguments
    if rhs <= 1 then
        nd = 2;
        lengths = [4 4];
    else
        
        var_list = list();
        for i = 2:rhs
            var_list($+1) = varargin(i);
        end

        // Use cellfun
        if or(cellfun("isnumeric", var_list) == 0) then
            error("checkerboard: SIZE or MxNx... list must be numeric");
        end
        
        first_var = var_list(1);
        if length(var_list) == 1 then
            if length(first_var) == 1 then // checkerboard(SIDE, M)
                lengths = [first_var, first_var];
            else // checkerboard(SIDE, [M N P ...])
                lengths = first_var;
            end
        else // checkerboard(SIDE, M, N, P, ...)
            // Use custom cellfun to check sizes with 'or'
            if or(cellfun("numel", var_list) > 1) then
                error("checkerboard: M, N, P, ... must be numeric scalars");
            end
            // Use custom cell2mat
            lengths = cell2mat(var_list);
        end
    end

    //Validate Lengths
    if min(lengths) < 0 | or(lengths <> floor(lengths)) then
        error("checkerboard: SIZE or MxNx... list must be non-negative integer");
    end
    nd = length(lengths);

    // Handle Empty Edge Cases
    if side == 0 | min(lengths) == 0 then
        sz = list();
        for i = 1:length(lengths)
            sz(i) = lengths(i) * 2 * side;
        end
        board = zeros(sz(:));
        return;
    end

    // Generate Grids --> nthargout custom
    vec = linspace(-1, 1, 2 * side);
    grids = nthargout_ndgrid(nd, vec);
    
    tile = grids(1);
    for d = 2:nd
        tile = tile .* grids(d);
    end
    
    
    tile = bool2s(tile < 0);
    
    board = repmat(tile, lengths);

    //Apply Grey Shading on the Left Side
    // In Scilab, we cannot easily use dynamic cell string indices like {":"}
    // So i use matrix reshaping to  target the 2nd dimension.
    expected_size = lengths * 2 * side;
    D1 = expected_size(1);
    D2 = expected_size(2);
    if length(expected_size) > 2 then
        D3 = prod(expected_size(3:$));
    else
        D3 = 1;
    end

    board_reshaped = matrix(board, D1, D2, D3);
    half_col = D2 / 2;
    board_reshaped(:, (half_col + 1):D2, :) = board_reshaped(:, (half_col + 1):D2, :) * 0.7;
    
    // Restore Original Shape
    board = matrix(board_reshaped, expected_size);

endfunction


// COMPATIBILITY LAYER 


function res = cellfun(func_name, C)
  
    res = zeros(1, length(C));
    
    for i = 1:length(C)
        item = C(i);
        select func_name
            case "isnumeric" then
                // bool2s guarantees Scilab outputs a safe 1 or 0
                res(i) = bool2s(type(item) == 1 | type(item) == 8);
            case "numel" then
                res(i) = length(item);
            else
                error("cellfun: unsupported function name in shim.");
        end
    end
endfunction

function mat = cell2mat(C)
    //  cell2mat, flattening a list into a row vector
    mat = [];
    for i = 1:length(C)
        mat = [mat, C(i)];
    end
endfunction

function grids = nthargout_ndgrid(nd, vec)

    grids = list();
    
    if nd == 1 then
        grids(1) = vec;
        return;
    end
    
    lhs_str = "[out1";
    for i = 2:nd
        lhs_str = lhs_str + ", out" + string(i);
    end
    lhs_str = lhs_str + "]";
    
    rhs_str = "ndgrid(";
    for i = 1:nd
        rhs_str = rhs_str + "vec";
        if i < nd then 
            rhs_str = rhs_str + ", "; 
        end
    end
    rhs_str = rhs_str + ")";
    
    execstr(lhs_str + " = " + rhs_str);
    
    for i = 1:nd
        execstr("grids(i) = out" + string(i));
    end
endfunction



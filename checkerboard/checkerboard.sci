exec("cellfun1.sci", -1);
funcprot(0); 

function [board] = checkerboard(side, varargin)

    rhs = argn(2);

    if rhs == 0 then
        side = 10;
    end

    if rhs > 0 & ~(isscalar(side) & isnumeric(side) & side == fix(side) & side >= 0) then
        error("checkerboard: SIDE must be a non-negative integer");
    end

    if length(varargin) == 0 then
        nd = 2;
        lengths = [4 4];
    else
        if or(~cellfun("isnumeric", varargin)) then
            error("checkerboard: SIZE or MxNx... list must be numeric");
        end

        first_var = varargin(1);
        if length(varargin) == 1 then
            if isscalar(first_var) then
                lengths = [first_var, first_var];
            else
                lengths = first_var;
            end
        else
            if or(cellfun("numel", varargin) > 1) then
                error("checkerboard: M, N, P, ... must be numeric scalars");
            end
            lengths = cell2mat(varargin);
        end
    end

    if ~(size(lengths,1) == 1 | size(lengths,2) == 1) | or(lengths < 0) | or(lengths <> fix(lengths)) then
        error("checkerboard: SIZE or MxNx... list must be non-negative integer");
    end
    nd = length(lengths);

    grids = nthargout(1:nd, "ndgrid", linspace(-1, 1, 2*side));
    
    if typeof(grids) == "list" then
        tile = grids(1);
        for d = 2:nd
            tile = tile .* grids(d);
        end
    else
        tile = grids;
    end
    
    tile = tile < 0;
    board = bool2s(repmat(tile, lengths));

    left_idx = list();
    for i = 1:nd
        left_idx(i) = ":";
    end

    nc = size(board, 2);
    left_idx(2) = string(nc/2 + 1) + ":" + string(nc);

    idx_str = "";
    for i = 1:nd
        idx_str = idx_str + left_idx(i);
        if i < nd then
            idx_str = idx_str + ",";
        end
    end

    execstr("board(" + idx_str + ") = board(" + idx_str + ") * 0.7;");

endfunction


function mat = cell2mat(C)
    mat = [];
    for i = 1:length(C)
        mat = [mat, C(i)];
    end
endfunction


function arg = nthargout (n, varargin)

    [lhs, rhs] = argn(0);
    
    if (rhs < 1) then
        error("nthargout: not enough input arguments");
    end

    // FIX 1: Safely get the number of elements in a Scilab list
    num_vargs = length(varargin);
    
    if (num_vargs < 1) then
        error("nthargout: not enough input arguments");
    end

    v1 = varargin(1);
    
    if (typeof(v1) == "function" | type(v1) == 10 | type(v1) == 11 | type(v1) == 13) then
        ntot = max(n);
        fcn = v1;
        args = list();
        for i = 2:num_vargs
            args($+1) = varargin(i);
        end
    elseif (isnumeric(v1) && (num_vargs >= 2)) then
        v2 = varargin(2);
        if (typeof(v2) == "function" | type(v2) == 10 | type(v2) == 11 | type(v2) == 13) then
            ntot = max(v1);
            fcn = v2;
            args = list();
            for i = 3:num_vargs
                args($+1) = varargin(i);
            end
        else
            error("nthargout: invalid input arguments");
        end
    else
        error("nthargout: invalid input arguments");
    end

    if (or(n <> floor(n)) || (ntot <> floor(ntot)) || or(n <= 0) || ntot <= 0) then
        error("nthargout: N and NTOT must be positive integers");
    end

    outargs = list();
    for i = 1:ntot
        outargs(i) = 0;
    end

    try
        lhs_str = "[";
        for i = 1:ntot
            if i > 1 then lhs_str = lhs_str + ", "; end
            lhs_str = lhs_str + "o_" + string(i);
        end
        lhs_str = lhs_str + "]";
        
        fcn_name = "ndgrid"; 
        if type(fcn) == 10 then
            fcn_name = fcn;
        end
        
        call_args = "";
        
        if (fcn_name == "ndgrid" | fcn_name == "meshgrid") & length(args) == 1 then
            for k = 1:ntot
                if k > 1 then call_args = call_args + ", "; end
                call_args = call_args + "args(1)";
            end
        else
            for k = 1:length(args)
                if k > 1 then call_args = call_args + ", "; end
                call_args = call_args + "args(" + string(k) + ")";
            end
        end
        
        execstr(lhs_str + " = " + fcn_name + "(" + call_args + ");");
        
        for i = 1:ntot
            execstr("outargs(i) = o_" + string(i) + ";");
        end
        
    catch
        err = lasterr();

        error("nthargout execution failed: " + strcat(err, " "));
    end

    if (length(n) > 1) then
        arg = list();
        for k = 1:length(n)
            arg(k) = outargs(n(k));
        end
    else
        arg = outargs(n);
    end

endfunction


function result = isscalar(x)
    result = (size(x, 1) == 1 & size(x, 2) == 1);
endfunction


function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction

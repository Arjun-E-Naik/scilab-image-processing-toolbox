exec("cellfun1.sci",-1);

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
            if isscalar(first_var) then // isscalar(first_var)
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

    grids = nthargout_ndgrid(nd, linspace(-1, 1, 2*side));
    tile = grids(1);
    for d = 2:nd
        tile = tile .* grids(d);
    end
    tile = tile < 0;
    board = bool2s(repmat(tile, lengths));

    // left_idx = repmat({":"}, 1, nd);
    left_idx = list();
    for i = 1:nd
        left_idx(i) = ":";
    end

    nc = size(board, 2);

    left_idx(2) = string(nc/2 + 1) + ":" + string(nc);

//      board(left_idx{:}) *= 0.7; --> below blocks.
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



function result = isscalar(x)
    result = (size(x, 1) == 1 & size(x, 2) == 1);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction

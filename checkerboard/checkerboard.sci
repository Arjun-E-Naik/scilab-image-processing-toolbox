

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

    // left_idx = repmat ({":"}, 1, nd); ---> {:} iterating in loop.
    left_idx = list();
    for i = 1:nd
        left_idx(i) = ":";
    end

    nc = size(board, 2);

    // left_idx{2} = (nc/2 +1):nc; ---> left_idx{:2}
    left_idx(2) = string(nc/2 + 1) + ":" + string(nc);


// board(left_idx{:}) *= 0.7; ---> below code handles {:} in loop
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


// cellfun()


function varargout = cellfun(varargin)
    // CELLFUN  Apply function to each cell element
    // Exact Scilab translation of Octave's cellfun (cellfun.cc)

    [lhs, rhs] = argn();

    if rhs < 2 then
        error("cellfun: at least two input arguments are required");
    end


    for i = 2:rhs
        if typeof(varargin(i)) == "list" then
            lst = varargin(i);
            lst_len = length(lst);
            if lst_len == 0 then
                c_tmp = cell();
            else
                c_tmp = cell(1, lst_len);
                for k = 1:lst_len
                    c_tmp{k} = lst(k);
                end
            end
            varargin(i) = c_tmp;
        end
    end

    fcn = varargin(1);


    uniform_output = %t;
    error_handler  = [];
    n_cell_inputs  = rhs - 1;          
    idx            = rhs;

    while idx > 3
        if type(varargin(idx-1)) == 10 then
            opt_name = convstr(varargin(idx-1), "l");
            opt_val  = varargin(idx);

            n_opt = max(length(opt_name), 2);
            
            if part(opt_name, 1:n_opt) == part("uniformoutput", 1:n_opt) then
                if opt_val == %t | opt_val == %f then
                    uniform_output = opt_val;
                else
                    error("cellfun: UniformOutput value must be boolean");
                end
                idx = idx - 2;
                n_cell_inputs = n_cell_inputs - 2;
            elseif part(opt_name, 1:n_opt) == part("errorhandler", 1:n_opt) then
                error_handler = opt_val;
                idx = idx - 2;
                n_cell_inputs = n_cell_inputs - 2;
            else
                break; 
            end
        else
            break;
        end
    end


    is_accel = %f;
    if type(fcn) == 10 then
        accel_fcns = ["isempty", "islogical", "isnumeric", "isreal", "length", "ndims", "numel", "prodofsize", "size", "isclass"];
        if or(fcn == accel_fcns) then
            is_accel = %t;
            // "size" and "isclass" take an extra argument if n_cell_inputs is 2
            if (fcn == "size" | fcn == "isclass") & n_cell_inputs == 2 then
                n_cell_inputs = 1; 
            end
        end
    end


    if is_accel then
        [ret, ok] = try_cellfun_accelfcns(varargin, rhs);
        if ok then
            varargout(1) = ret;
            return;
        end
    end

    if n_cell_inputs < 1 then
        error("cellfun: at least one cell array argument is required");
    end


    inputs  = list();
    isarray = [];
    nel     = 1;
    inputdims = [1 1];

    for j = 1:n_cell_inputs
        c = varargin(j+1);
        if typeof(c) <> "ce" then
            error("cellfun: arguments must be cells");
        end
        inputs(j) = c;
        sz = size(c);
        if prod(sz) > 1 then
            isarray(j) = %t;
            nel = prod(sz);
            if or(inputdims <> [1 1]) & or(sz <> inputdims) then
                error("cellfun: input cell dimensions mismatch");
            end
            inputdims = sz;
        else
            isarray(j) = %f;
        end
    end

    nargout1 = max(lhs, 1);


    if uniform_output then
        results = list();
        expected_nargout = [];

        for count = 1:nel
            args = list();
            for j = 1:n_cell_inputs
                cj = inputs(j);
                if isarray(j) then
                    args(j) = cj{count};
                else
                    args(j) = cj{1};
                end
            end

            [y, had_err] = fcn_eval(fcn, args, lhs, error_handler, count);

            if had_err then
                continue;
            end

            ylen = length(y);

            if count == 1 then
                if lhs == 0 then
                    if ylen > 0 & ~isempty(y(1)) then
                        expected_nargout = 1;
                    else
                        expected_nargout = 0;
                    end
                else
                    expected_nargout = 1;
                end
            end

            if ylen < expected_nargout then
                error("cellfun: function returned fewer than nargout values");
            end

            if expected_nargout > 0 then
                if count == 1 then
                    for j = 1:expected_nargout
                        val = y(j);
                        if prod(size(val)) <> 1 then
                            error("cellfun: all values must be scalars when UniformOutput = true");
                        end
                        results(j) = repmat(val, inputdims);
                    end
                else
                    for j = 1:expected_nargout
                        val = y(j);
                        if prod(size(val)) <> 1 then
                            error("cellfun: all values must be scalars when UniformOutput = true");
                        end
                        try
                            results(j)(count) = val;
                        catch
                            error("cellfun: all values should be of the same type when UniformOutput = true");
                        end
                    end
                end
            end
        end

        varargout = list();
        for j = 1:nargout1
            if j <= length(results) then
                varargout(j) = results(j);
            else
                varargout(j) = zeros(inputdims);
            end
        end

    else
        
        results = list();
        for j = 1:nargout1
            results(j) = cell(inputdims(1), inputdims(2));
        end

        have_output = %f;

        for count = 1:nel
            args = list();
            for j = 1:n_cell_inputs
                cj = inputs(j);
                if isarray(j) then
                    args(j) = cj{count};
                else
                    args(j) = cj{1};
                end
            end

            [y, had_err] = fcn_eval(fcn, args, lhs, error_handler, count);

            ylen = length(y);

            if lhs > 0 & ylen < lhs then
                error("cellfun: function returned fewer than nargout values");
            end

            if lhs > 0 | (lhs == 0 & ylen > 0 & ~isempty(y(1))) then
                have_output = %t;
                num_to_copy = min(ylen, nargout1);
                for j = 1:num_to_copy
                    tmp = results(j);
                    tmp{count} = y(j);
                    results(j) = tmp;
                end
            end
        end

        if have_output | prod(inputdims) == 0 then
            varargout = list();
            for j = 1:nargout1
                varargout(j) = results(j);
            end
        end
    end
endfunction


function [retval, success] = try_cellfun_accelfcns(args, num_in_args)
    retval  = [];
    success = %f;

    fcn_name = args(1);
    f_arg    = args(2);
    nel      = size(f_arg, "*");
    fdims    = size(f_arg);

    if fcn_name == "size" then
        if num_in_args == 3 then
            d = args(3);
            if d < 1 then
                error("cellfun: K must be a positive integer");
            end
            result = zeros(1, nel);
            for count = 1:nel
                el = f_arg{count};
                sz = size(el);
                if d <= length(sz) then
                    result(count) = sz(d);
                else
                    result(count) = 1;
                end
            end
            retval  = matrix(result, fdims(1), fdims(2));
            success = %t;
            return;
        elseif num_in_args == 2 then
            error("cellfun: accelerated function size requires dimension argument here");
        end

    elseif fcn_name == "isclass" then
        if num_in_args <> 3 then
            error("cellfun: accelerated function isclass must be called with exactly two arguments");
        end
        class_name = args(3);
        if type(class_name) <> 10 then
            error("cellfun: CLASS argument to isclass must be a string");
        end
        result = zeros(1, nel);
        for count = 1:nel
            result(count) = (typeof(f_arg{count}) == class_name);
        end
        retval  = matrix(result, fdims(1), fdims(2));
        success = %t;
        return;
    end

    if num_in_args > 2 then
        error("cellfun: accelerated function must be called with only one argument");
    end

    if fcn_name == "isempty" then
        result = zeros(1, nel);
        for count = 1:nel
            result(count) = isempty(f_arg{count});
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;

    elseif fcn_name == "islogical" then
        result = zeros(1, nel);
        for count = 1:nel
            result(count) = (typeof(f_arg{count}) == "boolean");
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;

    elseif fcn_name == "isnumeric" then
        result = zeros(1, nel);
        for count = 1:nel
            t = typeof(f_arg{count});
            result(count) = (t == "constant" | t == "int8"  | t == "int16" | ..
                             t == "int32"   | t == "int64" | t == "uint8" | ..
                             t == "uint16"  | t == "uint32"| t == "uint64");
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;

    elseif fcn_name == "isreal" then
        result = zeros(1, nel);
        for count = 1:nel
            result(count) = isreal(f_arg{count});
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;

    elseif fcn_name == "length" then
        result = zeros(1, nel);
        for count = 1:nel
            sz = size(f_arg{count});
            result(count) = max(sz);
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;

    elseif fcn_name == "ndims" then
        result = zeros(1, nel);
        for count = 1:nel
            result(count) = length(size(f_arg{count}));
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;

    elseif fcn_name == "numel" | fcn_name == "prodofsize" then
        result = zeros(1, nel);
        for count = 1:nel
            result(count) = size(f_arg{count}, "*");
        end
        retval = matrix(result, fdims(1), fdims(2)); success = %t;
    end
endfunction


function [retval, execution_error] = fcn_eval(fcn, inputlist, num_out_args, ..
                                              error_handler, count)
    retval = list();
    execution_error = %f;

    argstr = "";
    n = length(inputlist);
    for k = 1:n
        if k > 1 then argstr = argstr + ","; end
        argstr = argstr + "inputlist(" + string(k) + ")";
    end

    try
        if type(fcn) == 10 then
            if num_out_args <= 1 then
                execstr("tmp_0 = " + fcn + "(" + argstr + "); retval(1) = tmp_0");
            else
                tmpvars = "";
                for k = 1:num_out_args
                    if k > 1 then tmpvars = tmpvars + ","; end
                    tmpvars = tmpvars + "tmp_" + string(k);
                end
                execstr("[" + tmpvars + "] = " + fcn + "(" + argstr + ")");
                for k = 1:num_out_args
                    execstr("retval(" + string(k) + ") = tmp_" + string(k));
                end
            end
        else
            if num_out_args <= 1 then
                execstr("tmp_0 = fcn(" + argstr + "); retval(1) = tmp_0");
            else
                tmpvars = "";
                for k = 1:num_out_args
                    if k > 1 then tmpvars = tmpvars + ","; end
                    tmpvars = tmpvars + "tmp_" + string(k);
                end
                execstr("[" + tmpvars + "] = fcn(" + argstr + ")");
                for k = 1:num_out_args
                    execstr("retval(" + string(k) + ") = tmp_" + string(k));
                end
            end
        end
    catch
        if ~isempty(error_handler) then
            err_msg = lasterror();
            msg_struct = struct("identifier", "unknown", ..
                                "message",    err_msg, ..
                                "index",      count);

            errlist = list(msg_struct);
            for k = 1:length(inputlist)
                errlist(k+1) = inputlist(k);
            end

            earstr = "";
            for k = 1:length(errlist)
                if k > 1 then earstr = earstr + ","; end
                earstr = earstr + "errlist(" + string(k) + ")";
            end

            try
                if type(error_handler) == 10 then
                    if num_out_args <= 1 then
                        execstr("tmp_0 = " + error_handler + "(" + earstr + "); retval(1) = tmp_0");
                    else
                        tmpvars = "";
                        for k = 1:num_out_args
                            if k > 1 then tmpvars = tmpvars + ","; end
                            tmpvars = tmpvars + "tmp_" + string(k);
                        end
                        execstr("[" + tmpvars + "] = " + error_handler + "(" + earstr + ")");
                        for k = 1:num_out_args
                            execstr("retval(" + string(k) + ") = tmp_" + string(k));
                        end
                    end
                else
                    if num_out_args <= 1 then
                        execstr("tmp_0 = error_handler(" + earstr + "); retval(1) = tmp_0");
                    else
                        tmpvars = "";
                        for k = 1:num_out_args
                            if k > 1 then tmpvars = tmpvars + ","; end
                            tmpvars = tmpvars + "tmp_" + string(k);
                        end
                        execstr("[" + tmpvars + "] = error_handler(" + earstr + ")");
                        for k = 1:num_out_args
                            execstr("retval(" + string(k) + ") = tmp_" + string(k));
                        end
                    end
                end
            catch
                execution_error = %t;
                retval = list();
            end
        else
            execution_error = %t;
            error(lasterror());
        end
    end
endfunction


function y = lower(x)
    y = convstr(x, "l");
endfunction

function y = upper(x)
    y = convstr(x, "u");
endfunction

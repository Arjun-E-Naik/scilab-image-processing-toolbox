
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

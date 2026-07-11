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

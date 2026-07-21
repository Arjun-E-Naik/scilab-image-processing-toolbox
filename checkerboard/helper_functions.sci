



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



function BW = roicolor(A, p1, p2)
    [lhs, rhs] = argn(0);
    
   
    if (rhs < 2 | rhs > 3) then
        error("roicolor: Invalid number of input arguments.");
    end
    
    
    if (rhs == 2) then
        if (~isvector(p1)) then
            error("roicolor: v should be a vector.");
        end
        
       
        BW_bool = (zeros(A) <> 0); 
        
        
        for c = p1(:)'
            BW_bool = BW_bool | (A == c);
        end
        
      
        BW = bool2s(BW_bool);
        
    
    elseif (rhs == 3) then
        if (~isscalar(p1) | ~isscalar(p2)) then
            error("roicolor: low and high must be scalars.");
        end
        
        
        BW = bool2s((A >= p1) & (A <= p2));
    end
endfunction
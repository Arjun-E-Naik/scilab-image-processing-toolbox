function total = bwarea(bw)
    [lhs, rhs] = argn(0);

    if rhs <> 1 then
        error("bwarea: Exactly 1 argument is required.");
    end

    if ndims(bw) <> 2 then
        error("bwarea: input image must be a 2D image.");
    end

    T = type(bw);
    //  types: 1 (real/complex), 4 (boolean), 8 (integers)
    is_numeric_or_logical = (T == 1 | T == 4 | T == 8);
    
    if ~is_numeric_or_logical then
        error("bwarea: input must be numeric or logical.");
    end

    if T <> 4 then
        bw = (bw <> 0); // Convert non-zero numeric values to boolean
    end

    four = ones(2, 2);
    two = diag([1, 1]);

    
    fours = conv2(bool2s(bw), four);
    twos  = conv2(bool2s(bw), two);

    // 6. Calculate Bit-Quad Patterns
    nQ1 = sum(bool2s(fours == 1));
    nQ3 = sum(bool2s(fours == 3));
    nQ4 = sum(bool2s(fours == 4));
    nQD = sum(bool2s(fours == 2 & twos <> 1)); 
    nQ2 = sum(bool2s(fours == 2 & twos == 1)); 

    // 7. Compute Total Area
    total = 0.25 * nQ1 + 0.5 * nQ2 + 0.875 * nQ3 + nQ4 + 0.75 * nQD;
        
endfunction
